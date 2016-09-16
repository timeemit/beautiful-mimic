require 'tempfile'
require 'sidekiq'
require 'mongoid'

require_relative '../models/upload'
require_relative '../models/s3_upload'
require_relative '../models/mimic'
require_relative './mimic_maker'

environment_path = File.expand_path("../environments/#{ENV['SIDEKIQ_ENV']}.yml", __dir__)
redis = YAML::load_file( environment_path )['redis']
url = "#{redis['ip']}:#{redis['port']}"

if redis['password']
  url = "x:#{env['redis']['password']}@#{url}"
end

Mongoid.load!(environment_path, 'mongo')

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{url}" }
end
