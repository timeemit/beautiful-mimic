require 'yaml'

require 'rspec'
require 'mongo'
require 'mongoid'

require_relative '../lib/aws_authenticator'
require_relative '../lib/s3_upload'
require_relative '../lib/s3_upload/image'
require_relative '../models/upload'
require_relative '../models/uploader'
require_relative '../models/mimic'
require_relative '../workers/mimic_maker'

module SpecBase

  def self.vars
    @vars ||= YAML::load_file(self.environment_path)
  end

  def self.environment_path
    File.expand_path('../../environments/test.yml', __FILE__)
  end

  def self.initialize!
    AwsAuthenticator.authenticate!(vars)
    Mongoid.load!(environment_path, 'mongo')
  end

  def self.bucket
    vars['S3']['bucket']
  end

  def self.mongo
    mongo_vars = vars['mongo']['clients']['default']
    @mongo ||= Mongo::Client.new("mongodb://#{mongo_vars['hosts'][0]}/#{mongo_vars['database']}")
  end

end

RSpec.configure do |c|
  c.include SpecBase
  c.before(:suite) { SpecBase.initialize! }
  c.after(:suite) { Aws::S3::Bucket.new(SpecBase.bucket).clear! }
  c.after(:each) { SpecBase.mongo.database.drop }
end
