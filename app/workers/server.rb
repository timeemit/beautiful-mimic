require 'tempfile'

require 'sidekiq'
require 'mongoid'
require 'mini_magick'
require 'open3' # for process execution

require_relative '../lib/secret'
require_relative '../lib/aws_authenticator'
require_relative '../lib/model'
require_relative '../lib/s3_upload'
require_relative '../lib/s3_upload/image'
require_relative '../lib/s3_upload/trained_model'
require_relative '../models/mimic'
require_relative '../models/upload'
require_relative './mimic_maker'

Secret.set! ENV['SIDEKIQ_ENV']

Mongoid.load!(Secret.path, 'mongo')
AwsAuthenticator.authenticate!(Secret.config)

redis = Secret.config['redis']
url = "#{redis['ip']}:#{redis['port']}/#{redis['db']}"
if redis['password']
  url = "x:#{Secret.config['redis']['password']}@#{url}"
end

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{url}" }
end
