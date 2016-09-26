require_relative '../../spec_base'

describe S3Upload::TrainedModel do
  let(:file) { File.open(File.join(__dir__, '../../fixtures/marilyn-monroe.jpg')) }

  def upload(*opts)
    opts = opts[0] ? opts[0] : {}
    @upload ||= S3Upload::TrainedModel.new(
      file: file,
      file_hash: 'aaaaaaaaaa1111111111'
    )
  end

  it 'can be initialized' do
    expect do 
      upload
    end.to_not raise_error
  end

  it 'does not return signed urls' do
    expect( upload.signed_url ).to be nil
  end

  it 'can persist and read' do
    expect( upload.uploaded? ).to be false

    expect( upload.save! ).to be true
    expect( upload.uploaded? ).to be true

    tempfile = Tempfile.new('test')
    upload.download(tempfile.path)

    upload.file.rewind
    expect( tempfile.read ).to eql upload.file.read
  end
end
