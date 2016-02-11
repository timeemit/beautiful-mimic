require 'yaml'
require 'mongoid'
require_relative '../lib/aws_authenticator'
require_relative '../models/uploader'

environment = ARGV[0]
raise ArgumentError unless ['development', 'test', 'production'].include? environment

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
  begin
    uploader.save!
  rescue Mongoid::Errors::Validations => e
    p "Uploading: #{filename}: Validation Error"
    next
  end
end
