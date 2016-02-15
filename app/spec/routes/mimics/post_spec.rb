require_relative '../spec_helper'

describe 'POST /mimics' do
  before do
    Sidekiq::Testing.fake!
    expect(MimicMaker.jobs.size).to eql 0
  end

  def assert_success
    expect(Mimic.count).to eql 1
    expect(MimicMaker.jobs.size).to eql 1
  end

  def assert_failure
    expect(Mimic.count).to eql 0
    expect(MimicMaker.jobs.size).to eql 0
  end

  it 'Should 400 on an empty request' do
    post '/mimics'
    expect(last_response.status).to eq 400
    expect(JSON.parse(last_response.body)).to eq({"content_upload_id"=>["can't be blank"], "style_upload_id"=>["can't be blank"]})

    assert_failure
  end

  it 'Should 400 for nonexistent uploads' do
    post '/mimics', style_hash: 'blue', content_hash: 'red'
    expect(last_response.status).to eq 400
    expect(JSON.parse(last_response.body)).to eq({"content_upload_id"=>["can't be blank"], "style_upload_id"=>["can't be blank"]})

    assert_failure
  end

  it 'Succeeds for valid files' do
    Upload.create!(user_hash: 'neo', file_hash: 'red', filename: 'redpill.jpg')
    Upload.create!(user_hash: 'neo', file_hash: 'blue', filename: 'bluepill.jpg')

    post '/mimics', {content_hash: 'red', style_hash: 'blue'}, {'rack.session' => {user_hash: 'neo'}}
    expect(last_response.status).to eq 201
    expect(last_response.body).to eq ''

    assert_success
  end

  it 'Can associate style with a system upload' do
    Upload.create(file_hash: 'red', filename: 'redpill.jpg', user_hash: 'neo')
    Upload.create(file_hash: 'blue', filename: 'bluepill.jpg')

    post '/mimics', {content_hash: 'red', style_hash: 'blue'}, {'rack.session' => {user_hash: 'neo'}}
    expect(last_response.status).to eq 201
    expect(last_response.body).to eq ''

    assert_success
  end

  it 'Cannot associate content with a system upload' do
    Upload.create(file_hash: 'red', filename: 'redpill.jpg')
    Upload.create(file_hash: 'blue', filename: 'bluepill.jpg', user_hash: 'neo')

    post '/mimics', {content_hash: 'red', style_hash: 'blue'}, {'rack.session' => {user_hash: 'neo'}}
    expect(last_response.status).to eq 400
    expect(JSON.parse(last_response.body)).to eq({"content_upload_id"=>["can't be blank"]})

    expect(Mimic.count).to eql 0
  end
end
