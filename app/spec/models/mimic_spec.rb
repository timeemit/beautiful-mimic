require_relative '../spec_base'

describe Mimic do
  it 'requires a user hash' do
    mimic = Mimic.new
    expect(mimic.valid?).to be false
    mimic.user_hash = 'aaaa'
    expect(mimic.valid?).to be true
  end

  it 'associates with a content upload' do
    content_upload = Upload.create(user_hash: 'neo', filename: 'redpill', file_hash: 'truth')
    style_upload = Upload.create(user_hash: 'neo', filename: 'bluepill', file_hash: 'bliss')
    mimic = Mimic.new(user_hash: 'neo')
    expect(mimic.content_upload).to be nil

    # Assignment
    mimic.content_upload = content_upload
    expect(mimic.content_upload_id).to eql content_upload.id
    mimic.style_upload = style_upload
    expect(mimic.style_upload_id).to eql style_upload.id
    expect(mimic.valid?).to be true
    expect(mimic.save).to be true

    # Inverse
    expect(content_upload.content_mimics.first).to eql mimic
    expect(style_upload.style_mimics.first).to eql mimic
  end
end
