class Upload
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :user_hash, type: String # foreign key to user; system-wide upload if ABSENT
  field :filename, type: String # name of file --> used to look up in S3
  field :file_hash, type: String # SHA256 of file

  validates :user_hash, presence: false # No user has == available to the entire system
  validates :filename, presence: true, length: { maximum: 256 }
  validates :file_hash, presence: true, uniqueness: { scope: :user_hash }

end
