class Item < ActiveRecord::Base
  belongs_to :feed

  validates :feed_id, presence: true

  def self.latest(user)
    Item.joins(:feed).includes(:feed).where(feeds: { user_id: user.id }).order(published_at: :desc)
  end

  scope :by_tag_id, ->(tag_id) { joins(feed: :taggings).where(taggings: { tag_id: tag_id }) }
end
