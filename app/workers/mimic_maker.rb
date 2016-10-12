class SystemFailure < StandardError; end
class UploadError < StandardError; end

class MimicMaker
  include Sidekiq::Worker

  def perform(mimic_id)
    # Fetch records
    mimic = Mimic.find(mimic_id)

    # Download the images to tempfiles
    content = mimic.content_upload
    content_ext = File.extname(content.filename)
    content_tempfile = Tempfile.new([File.basename(content.filename), content_ext])
    style_model_tempfile = Tempfile.new(["#{mimic.style_hash}", '.jpg'])
    output_path = "output#{content_ext}"

    s3_content = S3Upload::Image.new(
      user_hash: content.user_hash,
      file_hash: content.file_hash
    )
    s3_style = S3Upload::TrainedModel.new(
      file_hash: mimic.style_hash
    )

    s3_content.download(content_tempfile.path, 'original')
    s3_style.download(style_model_tempfile.path)

    # Resize

    content_image = MiniMagick::Image.new(content_tempfile.path)
    width, height = content_image.dimensions
    content_image.resize '500x500>'

    # Compute

    command = [
      'python',
      'neural-style/generate.py',
      '--model', %Q('#{style_model_tempfile.path}'),
      '--gpu', '-1',
      '--out', %Q('#{output_path}'),
      %Q('#{content_tempfile.path}')
    ]

    return_value, output = nil, nil
    Open3.popen3(command.join(' ')) do |stdin, stdout, stderr, wait_thr|
      return_value = wait_thr.value
      output = "STDOUT: #{stdout.gets(nil)}\n\nSTDERR: #{stderr.gets(nil)}"
    end

    raise SystemFailure, "Error (#{return_value.exitstatus}):\n#{output}" unless return_value.success?

    # Resize to original

    output_image = MiniMagick::Image.new(output_path)
    if height < 1000 and width < 1000
      output_image.resize '1000x1000'
    else
      output_image.resize "#{width}x#{height}"
    end

    # Upload the results

    uploader = Uploader.new(mimic.user_hash, "#{content.filename}-mimic#{content_ext}", File.new(output_path))
    uploader.save!

    # Done!
    mimic.mimic_hash = uploader.s3_upload.file_hash
    mimic.computed_at = Time.now
    mimic.save

    # Garbage Collection
    content_tempfile.unlink
    style_model_tempfile.unlink
    File.delete(output_path)
  end
end
