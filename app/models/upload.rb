class Upload
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :user_hash, type: String # foreign key to user; system-wide upload if ABSENT
  field :file_hash, type: String # SHA256 of file --> used to look up in S3
  field :filename, type: String # name of file

  has_many :content_mimics, class_name: 'Mimic', inverse_of: :content_upload
  has_many :style_mimics, class_name: 'Mimic', inverse_of: :style_upload

  validates :user_hash, presence: false # No user hash == available to the entire system
  validates :filename, presence: true, length: { maximum: 256 }, format: /(\.jpg|\.jpeg|\.png|\.tiff)\z/
  validates :file_hash, presence: true, uniqueness: { scope: :user_hash }

end
