require 'aws-sdk'
require_relative '../lib/model'

class S3Upload < Model
  attr_accessor :file
  attr_accessor :filename
  attr_accessor :user_hash

  def initialize(bucket)
    @bucket = bucket
    super()
  end

  def file_url
    "https://#{@bucket}.s3.amazonaws.com/#{filename}"
  end

  def save!
    return false unless valid?

    key = "#{@user_hash}/original/#{filename}"

    begin
      s3.put_object(bucket: @bucket, key: key, body: file)
    rescue Exception => error
      p error
      p error.response

      return 'An error occurred while storing the image', 511
    end

    return true
  end

  private

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
