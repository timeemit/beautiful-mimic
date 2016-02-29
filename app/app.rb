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
require_relative 'routes/uploads'
require_relative 'routes/mimics'

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

get '/style' do
  'Sass stylesheet'

  scss :stylesheet, :style => :expanded
end
