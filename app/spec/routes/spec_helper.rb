require 'json'
require 'rack/test'
require 'sidekiq/testing'
require 'rspec'

ENV['RACK_ENV'] = 'test'

require_relative '../spec_base'
require_relative '../../app.rb'

module RSpecMixin
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

RSpec.configure do |c|
  c.include RSpecMixin 
  c.after(:each) { Sidekiq::Worker.clear_all }
end
