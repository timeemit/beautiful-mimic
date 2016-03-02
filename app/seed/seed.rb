require 'yaml'
require 'mongoid'
require_relative '../lib/aws_authenticator'
require_relative '../models/uploader'

environments = ['development', 'test', 'production']
environment = ARGV[0]
raise "Choose one of #{environments}" unless environments.include? environment

# Collect args
environment_path = File.expand_path("environments/#{environment}.yml", "#{__dir__}/..")
env = YAML.load_file(environment_path)
filepaths = Dir["#{__dir__}/images/*"]

# Initialize
Mongoid.load!(environment_path, 'mongo')
AwsAuthenticator.authenticate!(env)

# Execute
p "Uploading for environment: #{environment}"

filepaths.each do |filepath|
  filename = File.basename(filepath)

  p "Uploading: #{filename}"

  uploader = Uploader.new(
    env['S3']['bucket'],
    nil,
    filename,
    File.new(filepath)
  )
  unless uploader.save!
    p uploader.s3_upload.errors
    p uploader.upload.errors
    raise "Uploading: #{filename}: Invalid!"
  end
end
