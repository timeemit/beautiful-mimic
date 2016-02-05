require_relative '../spec_base'

describe Upload do
  it 'requires all fields' do
    upload = Upload.new
    expect(upload.valid?).to be false
    expect(upload.errors.messages[:filename]).to eql ["can't be blank"]
    expect(upload.errors.messages[:file_hash]).to eql ["can't be blank"]
  end
end
