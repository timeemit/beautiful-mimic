require_relative '../spec_base'

describe S3Upload do
  let(:upload) do
    upload = S3Upload.new('beautiful.mimic.development')
    upload.file = File.open(File.join(__dir__, '../fixtures/marilyn-monroe.jpg'))
    upload.filename = 'marilyn-monroe.jpg'
    upload.user_hash = 'aaaaaaaaaaaa'
    upload
  end

  it 'should exist!' do
    expect(1).to eq 1
  end

  it 'can be initialized' do
    expect do 
      S3Upload.new 'aa'
    end.to_not raise_error
  end

  it 'is not initially valid' do
    expect( S3Upload.new('aa').valid? ).to be false
  end

  it 'can be valid' do
    expect( upload.valid? ).to be true
    expect( upload.errors[:file] ).to be_empty
    expect( upload.errors[:filename] ).to be_empty
  end

  it 'it needs to be a small file' do
    allow( upload.file ).to receive(:size) { 2 ** 22 + 1 } # Oh noes!
    expect( upload.valid? ).to be false
    expect( upload.errors[:file] ).to_not be_empty
    expect( upload.errors[:filename] ).to be_empty
    expect( upload.errors[:user_hash] ).to be_empty
  end

  it 'it needs to have an appropriate file extension' do
    upload.filename = 'marilyn-monroe.exe' # Oh noes!
    expect( upload.valid? ).to be false
    expect( upload.errors[:file] ).to be_empty
    expect( upload.errors[:filename] ).to_not be_empty
    expect( upload.errors[:user_hash] ).to be_empty
  end

  it 'it needs to have a user hash' do
    upload.user_hash = ''
    expect( upload.valid? ).to be false
    expect( upload.errors[:file] ).to be_empty
    expect( upload.errors[:filename] ).to be_empty
    expect( upload.errors[:user_hash] ).to_not be_empty
  end

  it 'can persist and read' do
    expect( upload.save! ).to be true
    tempfile = Tempfile.new(upload.filename)
    upload.download(tempfile.path, 'original')
    upload.file.rewind
    expect( tempfile.read ).to eql upload.file.read
  end
end
