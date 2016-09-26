require 'tempfile'

require 'sidekiq'
require 'mongoid'
require 'mini_magick'

require_relative '../models/upload'
require_relative '../lib/secret'
require_relative '../lib/model'
require_relative '../lib/s3_upload'
require_relative '../lib/s3_upload/image'
require_relative '../lib/s3_upload/trained_model'
require_relative '../models/mimic'
require_relative './mimic_maker'

Secret.set! ENV['SIDEKIQ_ENV']

Mongoid.load!(Secret.path, 'mongo')

redis = Secret.config['redis']
url = "#{redis['ip']}:#{redis['port']}/#{redis['db']}"
if redis['password']
  url = "x:#{env['redis']['password']}@#{url}"
end

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{url}" }
end
