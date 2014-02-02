class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed
  acts_as_taggable

  accepts_nested_attributes_for :feed

  validates :user_id, presence: true
  validates :feed_id, uniqueness: { scope: :user_id }

  scope :search, ->(conditions) {
    scope = self
    conditions[:tag].presence.try do |tag_names|
      scope = scope.tagged_with(tag_names)
    end
    scope = scope.page(conditions[:page])
    scope
  }

  def subscribe
    return false if feed.nil? || feed.url.blank?

    persisted_feed = Feed.find_by(url: feed.url)
    if persisted_feed
      self.feed = persisted_feed
    else
      feed.load!
      feed.save!
    end
    save
  end


  def user_title
    title.presence || feed.title
  end

  def tags_string
    tags.map(&:name).join(', ')
  end
end
