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
    output_tempfile = Tempfile.new(["#{mimic.user_hash}-#{mimic.content_hash}-#{mimic.style_hash}", content_ext])

    s3_content = S3Upload::Image.new(
      user_hash: content.user_hash,
      file_hash: content.file_hash
    )
    s3_style = S3Upload::TrainedModel.new(
      file_hash: mimic.style_hash
    )

    s3_content.download(content_tempfile.path, 'original')
    s3_style.download(style_model_tempfile.path)

    # Compute

    environment = {
      'PATH' => '/opt/nvidia/cuda/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/aws/bin',
      'CPATH' => '/opt/nvidia/cuda/include:$CPATH',
      'LIBRARY_PATH' => '/opt/nvidia/cuda/lib:$LIBRARY_PATH',
      'LD_LIBRARY_PATH' => '/opt/nvidia/cuda/lib/:/opt/nvidia/cuda/lib64:$LD_LIBRARY_PATH'
    }
    command = [
      '/opt/beautiful-mimic/venv_2_7/bin/python',
      '/opt/beautiful-mimic/neural-style/generate.py',
      '--model', style_model_tempfile.path,
      '--gpu', '0',
      '--out', output_tempfile.path,
      content_tempfile.path
    ]
    options = {
      chdir: '/opt/beautiful-mimic/neural-style',
    }

    return_value, output = nil, nil
    Open3.popen3(environment, command.join(' '), options) do |stdin, stdout, stderr, wait_thr|
      return_value = wait_thr.value
      output = "STDOUT: #{stdout.gets(nil)}\n\nSTDERR: #{stderr.gets(nil)}"
    end

    raise SystemFailure, "Error (#{return_value.exitstatus}):\n#{output}" unless return_value.success?

    # Upload the results

    uploader = Uploader.new(mimic.user_hash, "#{content.filename}-mimic#{content_ext}", output_tempfile)

    if not uploader.save!
      raise UploadError, "Could not upload to S3: Upload -- #{uploader.upload.errors} S3Upload -- #{uploader.s3_upload.errors}"
    end

    # Done!
    mimic.mimic_hash = uploader.s3_upload.file_hash
    mimic.computed_at = Time.now
    mimic.save

    # Garbage Collection
    content_tempfile.unlink
    style_model_tempfile.unlink
    output_tempfile.unlink
  end
end
