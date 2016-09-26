class S3Upload::TrainedModel < S3Upload
  SYSTEM_KEY = 'SYSTEM'

  attr_reader :user_hash

  def initialize(*opts)
    super(*opts)
    # When we open up a user marketplace...
    # opts = opts[0] ? opts[0] : {}
    # @user_hash = opts[:user_hash]
    self
  end

  def bucket
    Secret.config['S3']['models_bucket']
  end

  def download(path)
    super(file_key, path)
  end

  def signed_url
    # Keep the model inaccessible
    nil
  end

  def uploaded?
    super(file_key)
  end

  def save!
    super(file, file_key)

    return true
  end

  private

  def file_key
    # key = @user_hash ? @user_hash : SYSTEM_KEY
    "#{SYSTEM_KEY}/#{@file_hash}"
  end
end
