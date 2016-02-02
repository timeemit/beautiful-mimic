require_relative '../spec_helper'

describe 'GET /uploads/:filename' do
  before do
    upload_image
  end

  it 'Can return the uploaded file' do
    get '/uploads/marilyn-monroe.jpg'
    expect(last_response.status).to eq 302
    expect(last_response.body).to eq ''
    expect(last_response.headers['Location']).to start_with 'https://s3-us-west-1.amazonaws.com/beautiful.mimic.tests'
    expect(last_response.headers['Location']).to include 'thumbs/marilyn-monroe.jpg'
    expect(last_response.headers['Location']).to_not include 'thumbs/marilyn-monroe.jpg/original'
  end

  it 'Can return the uploaded file' do
    get '/uploads/marilyn-monroe.jpg/original'
    expect(last_response.status).to eq 302
    expect(last_response.body).to eq ''
    expect(last_response.headers['Location']).to start_with 'https://s3-us-west-1.amazonaws.com/beautiful.mimic.tests'
    expect(last_response.headers['Location']).to_not include 'thumbs/marilyn-monroe.jpg'
    expect(last_response.headers['Location']).to include 'originals/marilyn-monroe.jpg'
  end
end
