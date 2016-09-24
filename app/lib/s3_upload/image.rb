class S3Upload::Image < S3Upload
  include Model
  SYSTEM_KEY = 'SYSTEM'

  attr_reader :user_hash

  def initialize(*opts)
    super(*opts)
    opts = opts[0] ? opts[0] : {}
    @user_hash = opts[:user_hash]
    self
  end

  def download(path, style='thumb')
    return false unless valid?

    super(file_key(style), path)
  end

  def signed_url(style=nil)
    style = 'thumb' unless style
    super(file_key(style))
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
      super(path, file_key)
    end

    file_path = File.unlink(thumbfile_path)

    return true
  end

  private

  def file_key(style)
    key = @user_hash ? @user_hash : SYSTEM_KEY
    key += "/#{style}s/#{@file_hash}"
  end

  def thumbfile_path
    thumbfile = "#{file.path}.thumb"
  end

  def validate!
    validate_file_size!
    validate_file_hash_presence!
  end

  def validate_file_size!
    unless file && file.size < 2 ** 30 # ~ 1 gigabyte
      add_error :file, 'File size must be less than 4MB'
    end
  end

  def validate_file_hash_presence!
    unless file_hash.is_a? String and not file_hash.empty?
      add_error :file_hash, 'File hash must be present'
    end
  end
end
