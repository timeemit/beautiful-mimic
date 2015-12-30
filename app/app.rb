require 'sinatra'
# require 'carrierwave'

# User Management

before do
  # Set a cookie with key `user_hash` to be a random hash 
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

get '/' do
  'First Time: Form for new mimic'
  'Return User: Index of mimics'
end

get '/uploads' do
  'Retrieve uploaded photos'
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
  # Use `carrierwave` ?
  # Or just `AWS::S3` and 'minimagick' ? 
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
