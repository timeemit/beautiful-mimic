require_relative '../spec_helper'

describe 'POST /uploads' do

  def fixture_file(filename='marilyn-monroe.jpg' , file_type='image/jpeg' )
    file_path = File.expand_path("../../../fixtures/#{filename}", __FILE__)
    Rack::Test::UploadedFile.new( file_path, file_type, true )
  end

  def upload_image(filename='marilyn-monroe.jpg')
    # Upload a photo
    post '/uploads', file: fixture_file(filename)
    expect(last_response.status).to eq 200
    expect(last_response.body).to_not eq ''
  end

  it 'Should 400 on an empty request' do
    post '/uploads'
    expect(last_response.status).to eq 400
    expect(last_response.body).to eq ''
  end

  it 'Should 400 for invalid files' do
    post '/uploads', file: fixture_file('bad.txt', 'text/plain')
    expect(last_response.status).to eq 400
    expect(last_response.body).to_not eq ''
  end

  it 'Ensures uniqueness' do
    # First should succeed
    post '/uploads', file: fixture_file
    expect(last_response.status).to eq 200
    expect(last_response.body).to_not eq ''

    # Duplicate should fail
    post '/uploads', file: fixture_file
    expect(last_response.status).to eq 400
    expect(JSON.parse(last_response.body)).to eq 'file_hash' => ['is already taken']
  end

  it 'Succeeds for valid files' do
    post '/uploads', file: fixture_file
    expect(last_response.status).to eq 200
    expect(last_response.body).to eq Upload.last.to_json(only: [:filename, :file_hash, :created_at, :user_hash])
  end
end
