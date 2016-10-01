require 'yaml'
require 'mongoid'
require 'mini_magick'

require_relative '../lib/secret'
require_relative '../lib/aws_authenticator'
require_relative '../lib/model'
require_relative '../lib/s3_upload'
require_relative '../lib/s3_upload/image'
require_relative '../models/upload'
require_relative '../models/uploader'

environments = ['development', 'test', 'production']
environment = ARGV[0]
raise "Choose one of #{environments}" unless environments.include? environment

# Collect args
Secret.set!(environment)
filepaths = Dir["#{__dir__}/images/*"]

# Initialize
Mongoid.load!(Secret.path, 'mongo')
AwsAuthenticator.authenticate!(Secret.config)

# Execute
p "Uploading for environment: #{environment}"

filepaths.each do |filepath|
  filename = File.basename(filepath)

  p "Uploading: #{filename}"

  uploader = Uploader.new(
    nil,
    filename,
    File.new(filepath)
  )
  unless uploader.save!
    p "Uploading: Error: #{filename}!"
    p uploader.s3_upload.errors
    p uploader.upload.errors
  end
end
