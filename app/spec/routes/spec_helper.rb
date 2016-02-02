require 'rack/test'
require 'rspec'

ENV['RACK_ENV'] = 'test'

require_relative '../spec_base'
require_relative '../../app.rb'

module RSpecMixin
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def fixture_file(filename='marilyn-monroe.jpg' , file_type='image/jpeg' )
    file_path = File.expand_path("../../fixtures/#{filename}", __FILE__)
    Rack::Test::UploadedFile.new( file_path, file_type, true )
  end

  def upload_image(filename='marilyn-monroe.jpg')
    # Upload a photo
    post '/uploads', file: fixture_file(filename)
    expect(last_response.status).to eq 200
    expect(last_response.body).to_not eq ''
  end
end

RSpec.configure do |c| 
  c.include RSpecMixin 
  c.include SpecBase
  c.before(:suite) { SpecBase.initialize! }
  c.after(:each) { SpecBase.mongo.database.drop }
  c.after(:suite) { Aws::S3::Bucket.new(SpecBase.bucket).clear! }
end
