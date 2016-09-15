require_relative '../spec_base'

describe Mimic do
  it 'requires a user hash' do
    Upload.create!(user_hash: 'neo', filename: 'redpill.png', file_hash: 'a')
    Upload.create!(user_hash: 'neo', filename: 'bluepill.png', file_hash: 'b')
    mimic = Mimic.new(content_hash: 'a', style_hash: 'b')
    expect(mimic.valid?).to be false
    mimic.user_hash = 'neo'
    expect(mimic.valid?).to be true
  end

  it 'enforces uniqueness' do
    # Setup
    Upload.create!(user_hash: 'neo', filename: 'redpill.png', file_hash: 'a')
    expect(Upload.count).to be 1

    opts = {user_hash: 'neo', content_hash: 'a', style_hash: 'a'}
    Mimic.create!(opts)
    expect(Mimic.count).to be 1

    # Identical mimic should be invalid
    expect(Mimic.new(opts)).to be_invalid
  end

  it 'allows for different content hashes' do
    # Setup
    upload_opts = {user_hash: 'neo', filename: 'redpill.png', file_hash: 'a'}
    Upload.create!(upload_opts)
    Upload.create!(upload_opts.merge(file_hash: 'z'))
    expect(Upload.count).to be 2

    opts = {user_hash: 'neo', content_hash: 'a', style_hash: 'a'}
    Mimic.create!(opts)
    expect(Mimic.count).to be 1

    # Different content hash should be fine
    expect(Mimic.new(opts.merge(content_hash: 'z'))).to be_valid
  end

  it 'allows for different style hashses' do
    # Setup
    upload_opts = {user_hash: 'neo', filename: 'redpill.png', file_hash: 'a'}
    Upload.create!(upload_opts)
    Upload.create!(upload_opts.merge(file_hash: 'z'))
    expect(Upload.count).to be 2

    opts = {user_hash: 'neo', content_hash: 'a', style_hash: 'a'}
    Mimic.create!(opts)
    expect(Mimic.count).to be 1

    # Different style hash should be fine
    expect(Mimic.new(opts.merge(style_hash: 'z'))).to be_valid
  end

  it 'allows for different user hashses' do
    upload_opts = {user_hash: 'neo', filename: 'redpill.png', file_hash: 'a'}
    Upload.create!(upload_opts)
    Upload.create!(upload_opts.merge(user_hash: 'zed'))
    expect(Upload.count).to be 2

    opts = {user_hash: 'neo', content_hash: 'a', style_hash: 'a'}
    Mimic.create!(opts)
    expect(Mimic.count).to be 1

    expect(Mimic.new(opts.merge(user_hash: 'zed'))).to be_valid
  end

  it 'requires a relevant content hash' do
    upload = Upload.create!(user_hash: 'neo', filename: 'redpill.png', file_hash: 'truth')
    mimic = Mimic.new(user_hash: 'neo', style_hash: upload.file_hash)
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
