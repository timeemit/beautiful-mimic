require 'yaml'
require 'securerandom'
require 'sinatra'
require 'aws-sdk'

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
  key = "#{session['user_hash']}/#{params['filename']}"
  signer = Aws::S3::Presigner.new

  begin
    url = signer.presigned_url(:get_object, {bucket: bucket, key: key, expires_in: 30})
  rescue Exception => error
    p error
    p error.response
  end

  redirect to(url)
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
  # `file_handle`: string
  #

  bucket = settings.env['S3']['bucket']

  # Validations
  unless params[:file].is_a? Hash
    return 'Must specify a file', 400
  end

  file = params[:file][:tempfile]
  filename = params[:file][:filename]

  if file.size > 2 ** 22 # ~ 4 megabytes
    return 'File size must be less than 4MB', 400
  elsif not %w(.jpg .jpeg .png .tiff).include? File.extname(filename)
    return 'File must be an image', 400
  end

  s3 = Aws::S3::Client.new
  key = "#{session['user_hash']}/#{filename}"

  begin
    s3.put_object(bucket: bucket, key: key, body: file)
  rescue Exception => error
    p error
    p error.response

    return 'An error occurred while storing the image', 511
  end

  url = "https://#{bucket}.s3.amazonaws.com/#{filename}"

  return url
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
