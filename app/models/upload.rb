class Upload
  # Upload Schema:
  # `user_hash`: string
  # `file_hash`: string
  # `filename`: string

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :user_hash, type: String # foreign key to user; system-wide upload if ABSENT
  field :file_hash, type: String # SHA256 of file --> used to look up in S3
  field :filename, type: String # name of file

  validates :user_hash, presence: false # No user hash == available to the entire system
  validates :filename, presence: true, length: { maximum: 256 }, format: /(\.jpg|\.jpeg|\.png|\.tiff)\z/
  validates :file_hash, presence: true, uniqueness: { scope: :user_hash }

  def content_mimics
    Mimic.where(user_hash: user_hash, content_hash: file_hash)
  end

  def style_mimics
    Mimic.where(user_hash: user_hash, style_hash: file_hash)
  end
end
