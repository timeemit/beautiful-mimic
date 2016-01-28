require_relative '../spec_helper'

describe 'POST /uploads' do
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

  it 'Succeeds for valid files' do
    post '/uploads', file: fixture_file
    expect(last_response.status).to eq 200
    expect(last_response.body).to_not eq ''
  end
end
