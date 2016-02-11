require_relative 'upload'
require_relative 's3_upload'
require_relative 'mimic'

class Uploader

  attr_reader :bucket, :user_hash, :filename, :file
  attr_reader :upload, :s3_upload

  def initialize(bucket, user_hash, filename, file)
    @bucket = bucket
    @user_hash = user_hash
    @filename = filename
    @file = file

    # SHA256 of file ensures uniqueness

    file_hash = Digest::SHA256.new.hexdigest file.read
    file.rewind

    # Objects

    @upload = Upload.new(
      user_hash: user_hash,
      filename: filename,
      file_hash: file_hash
    )

    @s3_upload = S3Upload.new(
      bucket: bucket,
      user_hash: user_hash,
      filename: filename,
      file: file
    )
  end

  def save!
    s3_upload.save! # => To S3
    upload.save!    # => To mongo
  end
end
