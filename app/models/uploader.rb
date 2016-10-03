class Uploader

  attr_reader :bucket, :user_hash, :filename, :file
  attr_reader :upload, :s3_upload

  def initialize(user_hash, filename, file)
    @user_hash = user_hash
    @filename = filename
    @file = file

    # Objects

    @s3_upload = S3Upload::Image.new(
      user_hash: user_hash,
      file: file
    )

    @upload = Upload.new(
      user_hash: user_hash,
      filename: filename,
      file_hash: @s3_upload.file_hash
    )
  end

  def save!
    return false unless s3_upload.valid? && upload.valid?
    s3_upload.save! && upload.save!    # => To S3, mongo, respectively
  end
end
