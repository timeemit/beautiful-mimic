require_relative '../spec_helper'

describe 'POST /mimics' do
  let(:model) { S3Upload::TrainedModel.new(file: File.open(File.join(__dir__, '../../fixtures/marilyn-monroe.jpg'))) }

  before do
    Sidekiq::Testing.fake!
    expect(MimicMaker.jobs.size).to eql 0
  end

  def assert_success
    mimic_id = Mimic.last.id.to_s
    expect(JSON.parse(last_response.body)).to eq({
      '_id' => {'$oid' => mimic_id},
      'content_hash' => 'red',
      'style_hash' => model.file_hash
    })
    expect(Mimic.count).to eql 1
    expect(MimicMaker.jobs.size).to eql 1
    expect(MimicMaker.jobs[0]['args']).to eql [mimic_id]
  end

  def assert_failure
    expect(Mimic.count).to eql 0
    expect(MimicMaker.jobs.size).to eql 0
  end

  it 'Should 400 on an empty request' do
    post '/mimics'
    expect(last_response.status).to eq 400
    expect(JSON.parse(last_response.body)).to eq({"content_hash"=>["can't be blank", "not uploaded"], "style_hash"=>["can't be blank", "not uploaded"]})

    assert_failure
  end

  it 'Should 400 for nonexistent uploads' do
    post '/mimics', style_hash: 'blue', content_hash: 'red'
    expect(last_response.status).to eq 400
    expect(JSON.parse(last_response.body)).to eq({"content_hash"=>["not uploaded"], "style_hash"=>["not uploaded"]})

    assert_failure
  end

  it 'Succeeds for valid files' do
    Upload.create!(user_hash: 'neo', file_hash: 'red', filename: 'redpill.jpg')
    model.save!

    post '/mimics', {content_hash: 'red', style_hash: model.file_hash}, {'rack.session' => {user_hash: 'neo'}}
    expect(last_response.status).to eq 201

    assert_success
  end

  it 'Returns success response for a resubmission' do
    Upload.create!(user_hash: 'neo', file_hash: 'red', filename: 'redpill.jpg')
    model.save!

    post '/mimics', {content_hash: 'red', style_hash: model.file_hash}, {'rack.session' => {user_hash: 'neo'}}
    expect(last_response.status).to eq 201

    assert_success
    Sidekiq::Worker.clear_all

    post '/mimics', {content_hash: 'red', style_hash: model.file_hash}, {'rack.session' => {user_hash: 'neo'}}
    expect(last_response.status).to eq 200

    assert_success
  end

  it 'Can associate style with a system upload' do
    Upload.create!(file_hash: 'red', filename: 'redpill.jpg', user_hash: 'neo')
    model.save!

    post '/mimics', {content_hash: 'red', style_hash: model.file_hash}, {'rack.session' => {user_hash: 'neo'}}
    expect(last_response.status).to eq 201

    assert_success
  end

  it 'Can associate content with a system upload' do
    Upload.create!(file_hash: 'red', filename: 'redpill.jpg')
    model.save!

    post '/mimics', {content_hash: 'red', style_hash: model.file_hash}, {'rack.session' => {user_hash: 'neo'}}
    expect(last_response.status).to eq 201

    assert_success
  end
end
