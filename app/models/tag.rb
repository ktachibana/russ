class Tag < ActiveRecord::Base
  belongs_to :user
  has_many :taggings, dependent: :destroy
  has_many :rss_sources, through: :taggings

  validates :name, presence: true, length: { maximum: 255 }, uniqueness: { scope: :user_id }
end
