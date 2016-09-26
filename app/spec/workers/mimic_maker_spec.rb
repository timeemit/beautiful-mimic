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
    output = double 'output', path: 'path3'
    expect( content ).to receive(:unlink)
    expect( style ).to receive(:unlink)
    expect( output ).to receive(:unlink)
    expect( Tempfile ).to receive(:new).and_return(content, style, output)
    expect( output ).to receive(:read).and_return('content')

    expect( S3Upload::Image  ).to receive(:new).with(
      user_hash: user_hash,
      file_hash: mimic.content_hash,
    ).and_call_original

    s3_upload_image = double('s3_upload_image', download: nil)
    expect( S3Upload::Image  ).to receive(:new).with(
      user_hash: user_hash,
      filename: 'beautiful_mimic',
      file: output
    ).and_return(s3_upload_image)
    expect( s3_upload_image ).to receive(:save!)

    environment = {
      'PATH' => '/usr/local/nvidia/cuda/bin:$PATH',
      'CPATH' => '/opt/nvidia/cuda/:$CPATH',
      'LIBRARY_PATH' => '/opt/nvidia/cuda/lib:$LIBRARY_PATH',
      'LD_LIBRARY_PATH' => '/opt/nvidia/cuda/lib/:/opt/nvidia/cuda/lib64:$LD_LIBRARY_PATH'
    }
    command = [
      '/opt/beautiful-mimic/venv_2_7/bin/python',
      '/opt/beautiful-mimic/neural-style/generate.py',
      '--model', style.path,
      '--gpu', '0',
      '--out', output.path,
      content.path
    ]
    options = {
      chdir: '/opt/beautiful-mimic',
      unsetenv_others: true
    }
    expect_any_instance_of( Kernel ).to receive(:system).with(environment, *command, *options)

    # Make the mimic!
    MimicMaker.new.perform(mimic.id)
  
    # Check the db
    mimic.reload
    expect( mimic.computed_at ).to be_a Time
    expect( mimic.mimic_hash ).to be_a String

    # Cleanup 
    File.delete 'path2'
  end
end
