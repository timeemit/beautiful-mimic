require 'yaml'          # For environment parsing
require 'securerandom'  # For random session user hashes
require 'sinatra'
require 'mongoid'

require_relative 'lib/aws_authenticator'
require_relative 'lib/sidekiq_client'
require_relative 'models/s3_upload'
require_relative 'models/upload'
require_relative 'models/mimic'
require_relative 'models/uploader'
require_relative 'workers/mimic_maker'

environment_path = File.expand_path("environments/#{settings.environment}.yml", __dir__)

enable :sessions
enable :logging
set :env, YAML::load_file( environment_path )
set :session_secret, 'qyAi9Y/mkwZo7Z0CFqtBqJr5ZE4oX0J3VVxU1PzGZV8='

# Initiialize

Mongoid.load!(environment_path, 'mongo')
AwsAuthenticator.authenticate!(settings.env)
SidekiqClient.connect!(settings.env)

PAGE_COUNT = 15

before do
  # Set a cookie with key `user_hash` to be a random hash
  session['user_hash'] ||= SecureRandom.hex(30)
end

# Views

get '/' do
  'First Time: Form for new mimic'
  'Return User: Index of mimics'
  user_hash = session['user_hash']

  redirect to('/mimics/new') unless Mimic.where(user_hash: user_hash).exists?

  erb :index
end

get '/mimics/new' do
  'Form for new new mimic'

  erb :new
end

get '/style' do
  'Sass stylesheet'

  scss :stylesheet, :style => :expanded
end

# User Management

post '/users' do
  'Create User'

  # User Schema
  # `created_at`: timestamp
  # `user_hash`: string
  # `email`: string ( not always present )
  # `confirmed_at`: timestamp ( present only after email )
  # `password_hash`: string ( present only after confirmed_at )
end

put '/users/password' do
  'Change Password'
end

put '/users/email' do
  'Change Email'
end

post '/sessions' do
  'Sign In'
end

get '/confirmations' do
  'Get Confirmation Number'
end

# Buesiness Logic

get '/uploads' do
  'COMPLETE,TESTED'
  'Retrieve uploaded photos'

  user_hash = session['user_hash']
  begin
    page = params['page'] || 1
    page = page.to_i
    raise unless page > 0
  rescue => e
    return 400
  end

  return Upload.
    in(user_hash: [user_hash, nil]).
    only(:filename, :file_hash, :created_at).
    sort(created_at: -1).
    limit(PAGE_COUNT).
    skip(PAGE_COUNT * (page - 1)).
    to_json(except: :_id)
end

get '/uploads/:file_hash' do
  'COMPLETE,TESTED'
  'Retrieve an uploaded photo'

  user_hash = session['user_hash']
  file_hash = params['file_hash']
  upload = Upload.
    in(user_hash: [user_hash, nil]).
    where(file_hash: file_hash).
    first

  return 401 unless upload

  bucket = settings.env['S3']['bucket']
  upload = S3Upload.new(
    bucket: bucket,
    user_hash: upload.user_hash, # May be nil in the case of system images
    file_hash: file_hash
  )

  redirect to(upload.signed_url)
end

get '/uploads/:file_hash/original' do
  'COMPLETE,TESTED'
  'Retrieve the original copy of an uploaded photo'

  user_hash = session['user_hash']
  file_hash = params['file_hash']
  upload = Upload.
    in(user_hash: [user_hash, nil]).
    where(file_hash: file_hash).
    first

  return 401 unless upload

  bucket = settings.env['S3']['bucket']
  upload = S3Upload.new(
    bucket: bucket,
    user_hash: upload.user_hash, # May be nil in the case of system images
    file_hash: file_hash
  )

  redirect to(upload.signed_url 'original')
end

post '/uploads' do
  'COMPLETE,TESTED'
  'Upload a new, private photo'

  # Processes a thumbnail and preview pics
  # Uploads file to S3
  # Saves handle to MongoDB record
  # Associate record with `user_hash`

  bucket = settings.env['S3']['bucket']
  user_hash = session['user_hash']

  # Ensure params structure

  begin
    file = params['file'][:tempfile]
    filename = params['file'][:filename]
  rescue => e
    return 400
  end

  uploader = Uploader.new(bucket, user_hash, filename, file)

  # Validations

  unless uploader.upload.valid?
    return 400, uploader.upload.errors.to_json
  end

  unless uploader.s3_upload.valid?
    return 400, uploader.s3_upload.errors.to_json
  end

  # Persit
  uploader.save!

  return uploader.upload.to_json(only: [:filename, :file_hash, :created_at])
end

post '/mimics' do
  'COMPLETED,TESTED'
  'Make a beautiful mimic'

  # Persist a mimic record
  # Queue a Sidekiq task

  user_hash = session['user_hash']

  begin
    content_hash = params[:content_hash]
    style_hash = params[:style_hash]
  rescue => e
    return 400, {message: 'invalid'}
  end

  # Object

  mimic = Mimic.new
  mimic.user_hash = user_hash
  mimic.content_hash = content_hash
  mimic.style_hash = style_hash

  # Validations

  unless mimic.valid?
    return 400, mimic.errors.to_json
  end

  # Persit

  mimic.save!    # => To mongo

  # Queue Job

  MimicMaker.perform_async(
    bucket = settings.env['S3']['bucket'],
    mimic.id
  )

  return 201
end

post '/unlock' do
  'Unlock mimics'

  # Pay for mimic(s) to be unlocked
end
