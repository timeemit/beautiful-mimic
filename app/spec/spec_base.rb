require 'yaml'
require 'rspec'
require 'mongo'

require_relative '../lib/aws_authenticator'

module SpecBase
  VARS = YAML::load_file( File.expand_path('../../environments/test.yml', __FILE__) )

  def self.initialize!
    AwsAuthenticator.authenticate!(VARS)
  end

  def self.bucket
    VARS['S3']['bucket']
  end

  def self.mongo
    mongo_vars = VARS['mongo']['clients']['default']
    @mongo ||= Mongo::Client.new("mongodb://#{mongo_vars['hosts'][0]}/#{mongo_vars['database']}")
  end

end
