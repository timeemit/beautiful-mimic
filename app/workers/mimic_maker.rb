class MimicMaker
  include Sidekiq::Worker

  def perform(bucket, mimic_id)
    # Fetch records
    mimic = Mimic.find(mimic_id)
    uploads = Upload.in(
      file_hash: [ mimic.content_hash, mimic.style_hash ]
    )
    if uploads.first.file_hash == mimic.content_hash
      content_upload = uploads.first
      style_upload = uploads.last
    else
      content_upload = uploads.last
      style_upload = uploads.first
    end

    # Download the images to tempfiles
    content_tempfile = Tempfile.new(content_upload.filename)
    style_tempfile = Tempfile.new(style_upload.filename)
    output_tempfile = Tempfile.new("#{mimic.user_hash}-#{content_upload.filename}-#{style_upload.filename}")

    s3_content = S3Upload.new(
      bucket: bucket,
      user_hash: mimic.user_hash,
      filename: content_upload.filename
    )
    s3_style = S3Upload.new(
      bucket: bucket,
      user_hash: mimic.user_hash,
      filename: style_upload.filename
    )
    
    s3_content.download(content_tempfile.path, 'original')
    s3_style.download(style_tempfile.path, 'original')

    # Compute

    %x(th neural_style.lua -print_iter 0 -style_image #{style_tempfile.path} -content_image #{content_tempfile.path} -output_image #{output_tempfile.path})

    # Upload the results

    s3_output = S3Upload.new(
      bucket: bucket,
      user_hash: mimic.user_hash,
      filename: "#{content_upload.filename}.mimic",
      file: output_tempfile
    )

    s3_output.save!

    # Done!

    mimic.mimic_hash = Digest::SHA256.new.hexdigest output_tempfile.read
    mimic.computed_at = Time.now
    mimic.save
  end
end
