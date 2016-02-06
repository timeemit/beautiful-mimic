require_relative '../spec_helper'

describe 'POST /mimics' do
  it 'Should 400 on an empty request' do
    post '/mimics'
    expect(last_response.status).to eq 400
    expect(JSON.parse(last_response.body)).to eq({"content_upload_id"=>["can't be blank"], "style_upload_id"=>["can't be blank"]})
  end

  it 'Should 400 for nonexistent uploads' do
    post '/mimics', style_hash: 'blue', content_hash: 'red'
    expect(last_response.status).to eq 400
    expect(JSON.parse(last_response.body)).to eq({"content_upload_id"=>["can't be blank"], "style_upload_id"=>["can't be blank"]})
    expect(Mimic.count).to eql 0
  end

  it 'Succeeds for valid files' do
    Upload.create(user_hash: 'neo', file_hash: 'red', filename: 'redpill')
    Upload.create(user_hash: 'neo', file_hash: 'blue', filename: 'bluepill')

    post '/mimics', {content_hash: 'red', style_hash: 'blue'}, {'rack.session' => {user_hash: 'neo'}}
    expect(last_response.status).to eq 201
    expect(last_response.body).to eq ''

    expect(Mimic.count).to eql 1
  end
  
  it 'Can associate style with a system upload' do
    Upload.create(file_hash: 'red', filename: 'redpill', user_hash: 'neo')
    Upload.create(file_hash: 'blue', filename: 'bluepill')

    post '/mimics', {content_hash: 'red', style_hash: 'blue'}, {'rack.session' => {user_hash: 'neo'}}
    expect(last_response.status).to eq 201
    expect(last_response.body).to eq ''

    expect(Mimic.count).to eql 1
  end

  it 'Can associate style with a system upload' do
    Upload.create(file_hash: 'red', filename: 'redpill')
    Upload.create(file_hash: 'blue', filename: 'bluepill', user_hash: 'neo')

    post '/mimics', {content_hash: 'red', style_hash: 'blue'}, {'rack.session' => {user_hash: 'neo'}}
    expect(last_response.status).to eq 400
    expect(JSON.parse(last_response.body)).to eq({"content_upload_id"=>["can't be blank"]})

    expect(Mimic.count).to eql 0
  end
end
