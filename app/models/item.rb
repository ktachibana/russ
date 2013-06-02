class Item < ActiveRecord::Base
  belongs_to :rss_source

  validates :rss_source_id, presence: true

  def self.latest(user)
    Item.joins(:rss_source).includes(:rss_source).where(rss_sources: { user_id: user.id }).order(published_at: :desc)
  end
end
