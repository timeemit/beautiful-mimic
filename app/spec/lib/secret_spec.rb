require_relative '../spec_base'

describe Secret do
  %w(development test production).each do |env|
    describe "for #{env}" do
      before(:each) do
        Secret.set! env
      end

      after(:each) do
        Secret.set! 'test'
      end

      it 'should have a path' do
        expect( Secret.path ).to eql File.expand_path("../../environments/#{env}.yml", __dir__)
      end

      it 'should have a config' do
        expect( Secret.config.keys ).to eql %w(canvaspop AWS S3 redis mongo)
        expect( Secret.config['canvaspop'].keys ).to eql %w(url access_key secret_key)
        expect( Secret.config['AWS'].keys ).to eql %w(access_key_id secret_access_key region)
        expect( Secret.config['S3'].keys ).to eql %w(bucket models_bucket)
        expect( Secret.config['redis'].keys ).to eql %w(ip port db password)
        expect( Secret.config['mongo']['clients'].keys ).to eql %w(default)
      end
    end
  end
end
