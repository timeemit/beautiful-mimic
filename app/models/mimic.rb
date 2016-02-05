class Mimic
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :user_hash, type: String # foreign key to user; system-wide upload if ABSENT
  field :computed_at, type: Time # set when the mimic is computed and successfully uploaded
  field :unlocked_at, type: Time # set when the user when the unlocks the mimic

  belongs_to :content_upload, class_name: 'Upload', inverse_of: :content_mimics
  belongs_to :style_upload, class_name: 'Upload', inverse_of: :style_mimics

  validates :user_hash, presence: true

end
