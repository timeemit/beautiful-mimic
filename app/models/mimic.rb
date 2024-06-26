class Mimic
  # Mimic Schema
  # `user_hash`: string
  # `computed_at`: timestamp ( not always present )
  # `unlocked_at`: timestamp ( not always present )
  # `content_id`: string ( reference to the uploads collection )
  # `style_id`: string ( reference to the uploads collection )

  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :user_hash, type: String # foreign key to user
  field :content_hash, type: String # foreign key to content upload
  field :style_hash, type: String # foreign key to style upload
  field :mimic_hash, type: String # set when the mimic is computed
  field :computed_at, type: Time # set when the mimic is computed

  validates :user_hash, presence: true, uniqueness: {scope: [:content_hash, :style_hash]}
  validates :content_hash, presence: true
  validates :style_hash, presence: true
  validate :content_upload_exists
  validate :style_upload_exists

  def content_upload
    Upload.find_by(file_hash: self.content_hash)
  end

  private

  def content_upload_exists 
    self.errors.add(:content_hash, 'not uploaded') unless Upload.
      in(user_hash: [user_hash, nil]).
      where(file_hash: content_hash).
      exists?
  end

  def style_upload_exists 
    self.errors.add(:style_hash, 'not uploaded') unless S3Upload::TrainedModel.new(file_hash: style_hash).uploaded?
  end
end
