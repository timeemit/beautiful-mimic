require 'yaml'          # For environment parsing
require 'digest'        # For SHA256
require 'securerandom'  # For random session user hashes
require 'sinatra'
require 'mongoid'

require_relative 'models/s3_upload'
require_relative 'models/upload'

Mongoid.load!('mongoid.yml')

enable :sessions
enable :logging
set :env, YAML::load_file(File.join(__dir__, 'environments', "#{settings.environment}.yml") )
set :session_secret, 'qyAi9Y/mkwZo7Z0CFqtBqJr5ZE4oX0J3VVxU1PzGZV8='

# Initiialize

aws_key = Aws::Credentials.new(
  settings.env['AWS']['access_key_id'],
  settings.env['AWS']['secret_access_key']
)

Aws.config.update({
  region: 'us-west-1',
  credentials: aws_key
})

# User Management

before do
  # Set a cookie with key `user_hash` to be a random hash 
  session['user_hash'] ||= SecureRandom.hex(30)
end

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

get '/' do
  'First Time: Form for new mimic'
  'Return User: Index of mimics'
  session['user_hash']
end

get '/uploads' do
  'Retrieve uploaded photos'
end

get '/uploads/:filename' do
  'Retrieve an uploaded photo'

  bucket = settings.env['S3']['bucket']
  upload = S3Upload.new(bucket)
  upload.user_hash = session['user_hash']
  upload.filename = params['filename']

  redirect to(upload.signed_url)
end

get '/uploads/:filename/original' do
  'Retrieve the original copy of an uploaded photo'

  bucket = settings.env['S3']['bucket']
  upload = S3Upload.new(bucket)
  upload.user_hash = session['user_hash']
  upload.filename = params['filename']

  redirect to(upload.signed_url 'original')
end

post '/uploads' do
  'Upload a new, private photo'

  # Processes a thumbnail and preview pics
  # Uploads file to S3
  # Saves handle to MongoDB record
  # Associate record with `user_hash`
  #
  # Upload Schema:
  # `user_hash`: string
  # `filename`: string
  #

  bucket = settings.env['S3']['bucket']
  user_hash = session['user_hash']

  # Ensure params structure

  begin
    file = params['file'][:tempfile]
    filename = params['file'][:filename]
  rescue => e
    return 400
  end

  # SHA256 of file ensures uniqueness

  file_hash = Digest::SHA256.new.hexdigest file.read
  file.rewind

  # Objects

  upload = Upload.new
  upload.user_hash = user_hash
  upload.filename = filename
  upload.file_hash = file_hash

  s3_upload = S3Upload.new bucket
  s3_upload.user_hash = user_hash
  s3_upload.filename = filename
  s3_upload.file = file

  # Validations
  #
  unless upload.valid?
    return 400, upload.errors.to_json
  end

  unless s3_upload.valid?
    return 400, s3_upload.errors.to_json
  end

  # Persit

  s3_upload.save! # => To S3
  upload.save!    # => To mongo

  return s3_upload.signed_url
end

get '/mimics/new' do
  'Form for new new mimic'
end

post '/mimics' do
  'Make a beautiful mimic'

  # Persist a mimic record
  # Queue a Sidekiq task
  #
  # Mimic Schema
  # `created_at`: timestamp
  # `user_hash`: string
  # `content_id`: string ( reference to the uploads collection )
  # `style_id`: string ( reference to the uploads collection )
  # `unlocked_at`: timestamp ( not always present )
end

post '/unlock' do
  'Unlock mimics'

  # Pay to for mimic(s) to be unlocked
end
