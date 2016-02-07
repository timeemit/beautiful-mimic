require 'tempfile'
require 'sidekiq'
require_relative '../models/upload'
require_relative '../models/s3_upload'
require_relative '../models/mimic'

class MimicMaker
  include Sidekiq::Worker

  def perform(bucket, mimic_id)
    # Fetch records
    mimic = Mimic.find(mimic_id)
    uploads = Upload.find(
      mimic.content_upload_id,
      mimic.style_upload_id
    )
    if uploads.first.id == mimic.content_upload_id
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

    %x(th neural_style.lua -print_iter 0 -style_image #{style_tempfile.path} -content_image #{content_tempfile.path})

    # Upload the results

    s3_output = S3Upload.new(
      bucket: bucket,
      user_hash: mimic.user_hash,
      filename: "#{content_upload.filename}.mimic",
      file: content_tempfile
    )

    s3_output.save!

    # Done!
    mimic.touch(:computed_at)
  end
end
