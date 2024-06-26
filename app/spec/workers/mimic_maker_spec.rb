require_relative '../spec_base'

describe MimicMaker do

  it 'creates a mimic' do
    user_hash = 'neo'

    content = Uploader.new(
      user_hash,
      'marilyn-monroe.jpg',
      File.open(File.join(__dir__, '../fixtures/marilyn-monroe.jpg'))
    )

    style = S3Upload::TrainedModel.new(
      file: File.open(File.join(__dir__, '../fixtures/frank-sinatra.jpg'))
    )

    expect( content.save! ).to be true
    expect( style.save! ).to be true

    mimic = Mimic.create!(
      user_hash: user_hash,
      content_hash: content.upload.file_hash,
      style_hash: style.file_hash,
    )

    expect( mimic.computed_at ).to be nil

    # Stubs and Doubles
    content = double 'content', path: 'path1'
    style = double 'style', path: 'path2'
    expect( content ).to receive(:unlink)
    expect( style ).to receive(:unlink)
    expect( Tempfile ).to receive(:new).and_return(content, style)

    output = double 'output'
    expect( File ).to receive(:new).with('output.jpg').and_return(output)
    expect( File ).to receive(:new).at_least(:once).and_call_original
    expect( File ).to receive(:delete).with('output.jpg')

    expect( S3Upload::Image ).to receive(:new).with(
      user_hash: user_hash,
      file_hash: mimic.content_hash,
    ).and_call_original

    expected_hash = 'hash'
    s3_upload_image = double('s3_upload_image', download: nil, valid?: true)
    expect( S3Upload::Image  ).to receive(:new).with(
      user_hash: user_hash,
      file: output
    ).and_return(s3_upload_image)
    expect( s3_upload_image ).to receive(:save!).and_return(true)
    expect( s3_upload_image ).to receive(:file_hash).twice.and_return(expected_hash)

    content_image = double('content_image', dimensions: [2001, 2000])
    expect(content_image).to receive(:resize).with('500x500>')
    expect( MiniMagick::Image ).to receive(:new).with('path1').and_return content_image

    output_image = double('content_image')
    expect(output_image).to receive(:resize).with('2001x2000')
    expect( MiniMagick::Image ).to receive(:new).with('output.jpg').and_return output_image

    command = [
      'python',
      'neural-style/generate.py',
      '--model', %Q('#{style.path}'),
      '--gpu', '-1',
      '--out', %q('output.jpg'),
      %Q('#{content.path}')
    ]
    responses = [
      double('stdin'),
      double('stdout', gets: 'output'),
      double('stderr', gets: 'errors'),
      double('wait_thr', value: double('value', success?: true, exitstatus: 0))
    ]
    expect( Open3 ).to receive(:popen3).with(command.join(' ')).and_yield(*responses)

    # Make the mimic!
    expect do
      MimicMaker.new.perform(mimic.id)
    end.to change{ Upload.count }.by 1
  
    # Check the db
    mimic.reload
    expect( mimic.computed_at ).to be_a Time
    expect( mimic.mimic_hash ).to be_a String
    expect( mimic.mimic_hash ).to eql expected_hash
  end
end
