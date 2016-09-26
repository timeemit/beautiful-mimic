require 'yaml'

require 'rspec'
require 'mongo'
require 'mongoid'
require 'sidekiq'
require 'mini_magick'

require_relative '../lib/secret'
require_relative '../lib/aws_authenticator'
require_relative '../lib/model'
require_relative '../lib/s3_upload'
require_relative '../lib/s3_upload/image'
require_relative '../lib/s3_upload/trained_model'
require_relative '../models/upload'
require_relative '../models/uploader'
require_relative '../models/mimic'
require_relative '../workers/mimic_maker'

module SpecBase

  def self.vars
    Secret.config
  end

  def self.environment_path
    Secret.path
  end

  def self.initialize!
    Secret.set!('test')
    AwsAuthenticator.authenticate!(vars)
    Mongoid.load!(environment_path, 'mongo')
  end

  def self.mongo
    mongo_vars = vars['mongo']['clients']['default']
    @mongo ||= Mongo::Client.new("mongodb://#{mongo_vars['hosts'][0]}/#{mongo_vars['database']}")
  end

end

RSpec.configure do |c|
  c.include SpecBase
  c.before(:suite) { SpecBase.initialize! }
  c.after(:suite) do
    Aws::S3::Bucket.new(Secret.config['S3']['bucket']).clear!
    Aws::S3::Bucket.new(Secret.config['S3']['models_bucket']).clear!
  end
  c.after(:each) { SpecBase.mongo.database.drop }
end
