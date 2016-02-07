require 'mini_magick'
require_relative '../lib/model'

class S3Upload < Model
  attr_reader :bucket
  attr_accessor :file
  attr_accessor :filename
  attr_accessor :user_hash

  def initialize(bucket)
    @bucket = bucket
    super()
  end

  def download(path, style='thumb')
    resp = s3.get_object(
      response_target: path,
      bucket: bucket,
      key: file_key(style)
    )
  end

  def signed_url(style='thumb')
    signer = Aws::S3::Presigner.new

    begin
      url = signer.presigned_url(:get_object, {bucket: bucket, key: file_key(style), expires_in: 30})
    rescue Exception => error
      p error
      p error.response
    end

    url
  end

  def resize!
    image = MiniMagick::Image.open(file.path)
    image.resize('100x100')
    image.write(thumbfile_path)
  end

  def save!
    return false unless valid?

    resize!

    file_keys_to_paths = {
      file_key('original') => file,
      file_key('thumb') => File.open(thumbfile_path)
    }

    file_keys_to_paths.each do |file_key, path|
      s3.put_object(bucket: @bucket, key: file_key, body: path)
    end

    file_path = File.unlink(thumbfile_path)

    return true
  end

  private

  def file_key(style)
    file_key = "#{@user_hash}/#{style}s/#{@filename}"
  end

  def thumbfile_path
    thumbfile = "#{file.path}.thumb"
  end

  def s3
    @s3 ||= Aws::S3::Client.new
  end

  def validate!
    validate_file_size!
    validate_file_extension!
    validate_user_hash_presence!
  end

  def validate_file_size!
    unless file && file.size < 2 ** 22 # ~ 4 megabytes
      add_error :file,  'File size must be less than 4MB'
    end
  end

  def validate_file_extension!
    unless filename and %w(.jpg .jpeg .png .tiff).include? File.extname(filename)
      add_error :filename, 'File must be an image'
    end
  end

  def validate_user_hash_presence!
    unless user_hash.is_a? String and not user_hash.empty?
      add_error :user_hash, 'Session user hash must be present'
    end
  end
end
