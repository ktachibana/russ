class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed
  acts_as_taggable

  validates :user_id, presence: true
  validates :feed_id, presence: true

  def user_title
    title.presence || feed.title
  end
end
