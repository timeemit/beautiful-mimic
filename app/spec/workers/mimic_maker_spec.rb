require_relative '../spec_base'

describe MimicMaker do

  it 'creates a mimic' do
    bucket = SpecBase.bucket
    user_hash = 'neo'

    marilyn = Uploader.new(
      bucket,
      user_hash,
      'marilyn-monroe.jpg',
      File.open(File.join(__dir__, '../fixtures/marilyn-monroe.jpg'))
    )

    frank = Uploader.new(
      bucket,
      user_hash,
      'frank-sinatra.jpg',
      File.open(File.join(__dir__, '../fixtures/frank-sinatra.jpg'))
    )

    expect( marilyn.save! ).to be true
    expect( frank.save! ).to be true

    mimic = Mimic.create(
      user_hash: user_hash,
      content_upload_id: marilyn.upload.id,
      style_upload_id: frank.upload.id,
    )

    expect( mimic.computed_at ).to be nil
    expect_any_instance_of( Kernel ).to receive(:`).with(/^th neural_style\.lua -print_iter 0 -style_image .+ -content_image .+ -output_image .+$/)
    MimicMaker.new.perform(bucket, mimic.id)
    expect( mimic.reload.computed_at ).to be_a Time
  end
end
