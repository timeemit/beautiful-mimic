require_relative '../spec_helper'

describe 'GET /uploads' do
  let(:user_hash) { 'neo' }

  def fixture_file(filename='marilyn-monroe.jpg' , file_type='image/jpeg' )
    file_path = File.expand_path("../../../fixtures/#{filename}", __FILE__)
    Rack::Test::UploadedFile.new( file_path, file_type, true )
  end

  def upload_image(filename='marilyn-monroe.jpg')
    # Upload a photo
    post '/uploads', { file: fixture_file(filename)}
    expect(last_response.status).to eq 200
    expect(last_response.body).to_not eq ''
  end

  before do
    upload_image
  end

  it 'Can return the uploaded file thumb' do
    get '/uploads/marilyn-monroe.jpg'
    expect(last_response.status).to eq 302
    expect(last_response.body).to eq ''
    expect(last_response.headers['Location']).to start_with 'https://s3-us-west-1.amazonaws.com/beautiful.mimic.tests'
    expect(last_response.headers['Location']).to include 'thumbs/marilyn-monroe.jpg'
    expect(last_response.headers['Location']).to_not include 'thumbs/marilyn-monroe.jpg/original'
  end

  it 'Can return the original uploaded file' do
    get '/uploads/marilyn-monroe.jpg/original'
    expect(last_response.status).to eq 302
    expect(last_response.body).to eq ''
    expect(last_response.headers['Location']).to start_with 'https://s3-us-west-1.amazonaws.com/beautiful.mimic.tests'
    expect(last_response.headers['Location']).to_not include 'thumbs/marilyn-monroe.jpg'
    expect(last_response.headers['Location']).to include 'originals/marilyn-monroe.jpg'
  end

  it 'Can retrive all of the previous submissions' do
    upload_image('frank-sinatra.jpg')
    get '/uploads'
    expect(last_response.status).to eq 200
    expect(last_response.body).to_not eq ''
    records = JSON.parse(last_response.body)
    expect(records.length).to eql 2
    expect(records.first['filename']).to eql 'frank-sinatra.jpg' # Uploaded most recently
    expect(records.last['filename']).to eql 'marilyn-monroe.jpg' # Uploaded least recently
  end

  it 'Validates the page' do
    get '/uploads?page=0'
    expect(last_response.status).to eq 400
    expect(last_response.body).to eq ''
  end

  it 'Can paginate the response' do
    upload_image('frank-sinatra.jpg')
    stub_const('PAGE_COUNT', 1)
    get '/uploads'
    expect(last_response.status).to eq 200
    expect(last_response.body).to_not eq ''
    records = JSON.parse(last_response.body)
    expect(records.length).to eql 1
    expect(records.first['filename']).to eql 'frank-sinatra.jpg' # Uploaded most recently

    get '/uploads', page: 2
    expect(last_response.status).to eq 200
    expect(last_response.body).to_not eq ''
    records = JSON.parse(last_response.body)
    expect(records.length).to eql 1
    expect(records.first['filename']).to eql 'marilyn-monroe.jpg' # Uploaded most recently
  end
end
