require_relative '../spec_base'

describe Mimic do
  let(:model) { S3Upload::TrainedModel.new(file: File.open(File.join(__dir__, '../fixtures/marilyn-monroe.jpg'))) }

  it 'requires a user hash' do
    model.save!
    Upload.create!(user_hash: 'neo', filename: 'redpill.png', file_hash: 'a')
    mimic = Mimic.new(content_hash: 'a', style_hash: model.file_hash)
    expect(mimic.valid?).to be false
    mimic.user_hash = 'neo'
    expect(mimic.valid?).to be true
  end

  it 'relates to a content upload' do
    model.save!
    upload = Upload.create!(user_hash: 'neo', filename: 'redpill.png', file_hash: 'a')
    mimic = Mimic.new(user_hash: 'neo', content_hash: 'a', style_hash: model.file_hash)
    expect(mimic.valid?).to be true
    expect(mimic.content_upload).to eql upload
  end

  it 'enforces uniqueness' do
    # Setup
    model.save!
    Upload.create!(user_hash: 'neo', filename: 'redpill.png', file_hash: 'a')
    expect(Upload.count).to be 1

    opts = {user_hash: 'neo', content_hash: 'a', style_hash: model.file_hash}
    Mimic.create!(opts)
    expect(Mimic.count).to be 1

    # Identical mimic should be invalid
    expect(Mimic.new(opts)).to be_invalid
  end

  it 'allows for different content hashes' do
    # Setup
    model.save!
    upload_opts = {user_hash: 'neo', filename: 'redpill.png', file_hash: 'a'}
    Upload.create!(upload_opts)
    Upload.create!(upload_opts.merge(file_hash: 'z'))
    expect(Upload.count).to be 2

    opts = {user_hash: 'neo', content_hash: 'a', style_hash: model.file_hash}
    Mimic.create!(opts)
    expect(Mimic.count).to be 1

    # Different content hash should be fine
    expect(Mimic.new(opts.merge(content_hash: 'z'))).to be_valid
  end

  it 'allows for different style hashses' do
    # Setup
    model.save!
    upload_opts = {user_hash: 'neo', filename: 'redpill.png', file_hash: 'a'}
    Upload.create!(upload_opts)
    expect(Upload.count).to be 1

    opts = {user_hash: 'neo', content_hash: 'a', style_hash: model.file_hash}
    Mimic.create!(opts)
    expect(Mimic.count).to be 1

    # Different style hash should be fine
    other_model = S3Upload::TrainedModel.new(file: File.open(File.join(__dir__, '../fixtures/frank-sinatra.jpg')))
    other_model.save!
    expect(Mimic.new(opts.merge(style_hash: other_model.file_hash))).to be_valid
  end

  it 'allows for different user hashses' do
    model.save!
    upload_opts = {user_hash: 'neo', filename: 'redpill.png', file_hash: 'a'}
    Upload.create!(upload_opts)
    Upload.create!(upload_opts.merge(user_hash: 'trinity'))
    expect(Upload.count).to be 2

    opts = {user_hash: 'neo', content_hash: 'a', style_hash: model.file_hash}
    Mimic.create!(opts)
    expect(Mimic.count).to be 1

    expect(Mimic.new(opts.merge(user_hash: 'trinity'))).to be_valid
  end

  it 'requires a relevant content hash' do
    model.save!
    mimic = Mimic.new(user_hash: 'neo', style_hash: model.file_hash)
    expect(mimic).to be_invalid
    expect(mimic.errors.full_messages).to eql ["Content hash can't be blank", "Content hash not uploaded"]
  end

  it 'requires a relevant style hash' do
    upload = Upload.create!(user_hash: 'neo', filename: 'redpill.png', file_hash: 'truth')
    mimic = Mimic.new(user_hash: 'neo', content_hash: upload.file_hash)
    expect(mimic).to be_invalid
    expect(mimic.errors.full_messages).to eql ["Style hash can't be blank", "Style hash not uploaded"]
  end
end
