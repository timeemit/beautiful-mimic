require_relative '../../spec_base'

describe S3Upload::Image do
  let(:file) { File.open(File.join(__dir__, '../../fixtures/marilyn-monroe.jpg')) }

  def upload(*opts)
    opts = opts[0] ? opts[0] : {}
    @upload ||= S3Upload::Image.new(
      file: opts[:file] || file,
      file_hash: opts[:file_hash] || 'aaaaaaaaaa1111111111',
      user_hash: opts[:user_hash] || 'aaaaaaaaaaaa'
    )
  end

  it 'should exist!' do
    expect(1).to eq 1
  end

  it 'can be initialized' do
    expect do 
      upload
    end.to_not raise_error
  end

  it 'is not initially valid' do
    expect( S3Upload::Image.new.valid? ).to be false
  end

  it 'can be valid' do
    expect( upload.valid? ).to be true
    expect( upload.errors[:file] ).to be_nil
    expect( upload.errors[:filename] ).to be_nil
  end

  it 'needs to be a small file' do
    allow( file ).to receive(:size) { 2 ** 30 + 1 } # Oh noes!
    expect( upload.valid? ).to be false
    expect( upload.errors[:file] ).to_not be_nil
    expect( upload.errors[:filename] ).to be_nil
    expect( upload.errors[:user_hash] ).to be_nil
  end

  it 'can persist and read' do
    expect( upload.save! ).to be true
    tempfile = Tempfile.new('test')
    upload.download(tempfile.path, 'original')
    upload.file.rewind
    expect( tempfile.read ).to eql upload.file.read
  end
end
