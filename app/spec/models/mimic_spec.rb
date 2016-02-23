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

  it 'requires a relevant content hash' do
    upload = Upload.create!(user_hash: 'neo', filename: 'redpill.png', file_hash: 'truth')
    mimic = Mimic.new(user_hash: 'neo', style_hash: upload.file_hash)
    expect(mimic.valid?).to be false
    expect(mimic.errors.full_messages).to eql ["Content hash can't be blank", "Content hash not uploaded"]
  end

  it 'requires a relevant style hash' do
    upload = Upload.create!(user_hash: 'neo', filename: 'redpill.png', file_hash: 'truth')
    mimic = Mimic.new(user_hash: 'neo', content_hash: upload.file_hash)
    expect(mimic.valid?).to be false
    expect(mimic.errors.full_messages).to eql ["Style hash can't be blank", "Style hash not uploaded"]
  end

  it 'associates with a content upload' do
    content_upload = Upload.create!(user_hash: 'neo', filename: 'redpill.png', file_hash: 'truth')
    style_upload = Upload.create!(user_hash: 'neo', filename: 'bluepill.png', file_hash: 'bliss')
    mimic = Mimic.new(user_hash: 'neo')
    expect(mimic.content_upload).to be nil
    expect(mimic.style_upload).to be nil

    # Assignment
    mimic.content_hash = content_upload.file_hash
    mimic.style_hash = style_upload.file_hash
    expect(mimic.content_hash).to_not be nil
    expect(mimic.style_hash).to_not be nil

    # Assert
    expect(mimic.content_upload).to eql content_upload
    expect(mimic.style_upload).to eql style_upload

    # Persist
    expect(mimic.valid?).to be true
    expect(mimic.save).to be true

    # Inverse
    expect(content_upload.content_mimics.first).to eql mimic
    expect(style_upload.style_mimics.first).to eql mimic
  end
end
