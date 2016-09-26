class S3Upload
  attr_reader :file
  attr_reader :file_hash

  def initialize(*opts)
    opts = opts[0] ? opts[0] : {}
    if opts[:file]
      @file = opts[:file]
      @file_hash = Digest::SHA256.new.hexdigest(file.read)
      file.rewind
    else
      @file_hash = opts[:file_hash]
    end

    self
  end

  def download(key, path)
    resp = s3.get_object(
      response_target: path,
      bucket: bucket,
      key: key
    )
  end

  def signed_url(key)
    signer = Aws::S3::Presigner.new

    begin
      url = signer.presigned_url(:get_object, {bucket: bucket, key: key, expires_in: 30})
    rescue Exception => error
      p error
    end

    url
  end

  def uploaded?(key)
    Aws::S3::Object.new(bucket, key, client: s3).exists?
  end

  def save!(file_path, key)
    s3.put_object(bucket: @bucket, key: key, body: file_path)
  end

  private

  def s3
    @s3 ||= Aws::S3::Client.new
  end

  def bucket
    raise NotImplementedError
  end
end
