class SystemFailure < StandardError; end

class MimicMaker
  include Sidekiq::Worker

  def perform(mimic_id)
    # Fetch records
    mimic = Mimic.find(mimic_id)

    # Download the images to tempfiles
    content_tempfile = Tempfile.new(mimic.content_upload.filename)
    style_model_tempfile = Tempfile.new("#{mimic.style_hash}.jpg")
    output_tempfile = Tempfile.new("#{mimic.user_hash}-#{mimic.content_hash}-#{mimic.style_hash}")

    s3_content = S3Upload::Image.new(
      user_hash: mimic.user_hash,
      file_hash: mimic.content_hash
    )
    s3_style = S3Upload::TrainedModel.new(
      file_hash: mimic.style_hash
    )

    s3_content.download(content_tempfile.path, 'original')
    s3_style.download(style_model_tempfile.path)

    # Compute

    environment = {
      'PATH' => '/usr/local/nvidia/cuda/bin:$PATH',
      'CPATH' => '/opt/nvidia/cuda/:$CPATH',
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
      chdir: '/opt/beautiful-mimic',
      unsetenv_others: true
    }

    return_value, output = nil, nil
    Open3.popen3(environment, command.join(' '), options) do |stdin, stdout, stderr, wait_thr|
      return_value = wait_thr.value
      output = "STDOUT: #{stdout.gets(nil)}\n\nSTDERR: #{stderr.gets(nil)}"
    end

    raise SystemFailure, "Error (#{return_value.exitstatus}):\n#{output}" unless return_value.success?

    # Upload the results

    s3_output = S3Upload::Image.new(
      user_hash: mimic.user_hash,
      filename: 'beautiful_mimic',
      file: output_tempfile
    )

    s3_output.save!

    # Done!
    mimic.mimic_hash = Digest::SHA256.new.hexdigest output_tempfile.read
    mimic.computed_at = Time.now
    mimic.save

    # Garbage Collection
    content_tempfile.unlink
    style_model_tempfile.unlink
    output_tempfile.unlink
  end
end
