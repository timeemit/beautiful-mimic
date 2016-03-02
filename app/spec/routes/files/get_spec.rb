require_relative '../spec_helper'

describe 'GET /files' do

  let(:user_hash) { 'neo' }
  let(:file_hash) { 'aaaa' }
  let(:s3_url) { 'https://s3-us-west-1.amazonaws.com' }
  let(:bucket) { SpecBase.vars['S3']['bucket'] }
  let(:expected_url_prefix) { "#{s3_url}/#{bucket}" }

  it 'Can return the uploaded file thumb' do
    get "/files/#{file_hash}", {}, {'rack.session' => {user_hash: user_hash}}
    expect(last_response.status).to eq 302
    expect(last_response.body).to eq ''
    expect(last_response.headers['Location']).to start_with expected_url_prefix
    expect(last_response.headers['Location']).to start_with "#{expected_url_prefix}/#{user_hash}/thumbs/#{file_hash}"
    expect(last_response.headers['Location']).to_not include 'original'
  end

  it 'Can return the originally uploaded file' do
    get "/files/#{file_hash}", {style: 'original'}, {'rack.session' => {user_hash: user_hash}}
    expect(last_response.status).to eq 302
    expect(last_response.body).to eq ''
    expect(last_response.headers['Location']).to start_with expected_url_prefix
    expect(last_response.headers['Location']).to start_with "#{expected_url_prefix}/#{user_hash}/originals/#{file_hash}"
    expect(last_response.headers['Location']).to_not include 'thumb'
  end

  it 'Can return the originally uploaded system file' do
    get "/files/#{file_hash}", {system: 'true'}, {'rack.session' => {user_hash: user_hash}}
    expect(last_response.status).to eq 302
    expect(last_response.body).to eq ''
    expect(last_response.headers['Location']).to start_with expected_url_prefix
    expect(last_response.headers['Location']).to start_with "#{expected_url_prefix}/SYSTEM/thumbs/#{file_hash}"
    expect(last_response.headers['Location']).to_not include 'original'
  end

  it 'Can return the originally uploaded system file' do
    get "/files/#{file_hash}", {style: 'original', system: 'true'}, {'rack.session' => {user_hash: user_hash}}
    expect(last_response.status).to eq 302
    expect(last_response.body).to eq ''
    expect(last_response.headers['Location']).to start_with expected_url_prefix
    expect(last_response.headers['Location']).to start_with "#{expected_url_prefix}/SYSTEM/originals/#{file_hash}"
    expect(last_response.headers['Location']).to_not include 'thumb'
  end

end
