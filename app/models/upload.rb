class Upload
  include Mongoid::Document

  field :user_hash, type: String
  field :filename, type: String

  validates :user_hash, presence: true
  validates :filename, presence: true, length: { maximum: 256 }

end
