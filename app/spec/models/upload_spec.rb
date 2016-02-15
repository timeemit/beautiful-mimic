require_relative '../spec_base'

describe Upload do
  let(:valid_upload) { Upload.new(filename: 'marilyn-monroe.jpg', file_hash: 'aaaa0000') }

  it 'can be valid' do
    expect(valid_upload.valid?).to be true
  end

  it 'requires all fields' do
    upload = Upload.new
    expect(upload.valid?).to be false
    expect(upload.errors.messages[:filename]).to eql ["can't be blank", "is invalid"]
    expect(upload.errors.messages[:file_hash]).to eql ["can't be blank"]
    expect(upload.errors.messages[:user_hash]).to be nil
  end

  it 'needs to have an appropriate file extension' do
    upload = valid_upload
    upload.filename = 'marilyn-monroe.exe' # Oh noes!
    expect( upload.valid? ).to be false
    expect(upload.errors.messages[:filename]).to eql ["is invalid"]
    expect(upload.errors.messages[:user_hash]).to be nil
  end
end
