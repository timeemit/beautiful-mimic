class S3Upload
  attr_reader :file
  attr_reader :bucket

  def initialize(*opts)
    opts = opts[0] ? opts[0] : {}
    @bucket = opts[:bucket]
    @file = opts[:file]
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


  def save!(file_path, key)
    s3.put_object(bucket: @bucket, key: key, body: file_path)
  end

  private

  def s3
    @s3 ||= Aws::S3::Client.new
  end

end
