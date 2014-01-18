class Item < ActiveRecord::Base
  belongs_to :feed

  validates :feed_id, presence: true

  default_scope { order(published_at: :desc) }
  scope :user, ->(user) { joins(:feed).includes(:feed).merge(Feed.where(user_id: user.id)) }
  scope :search, ->(conditions) {
    scope = all
    conditions[:tag_ids].presence.try do |tag_ids|
      scope = scope.by_tag_id(tag_ids)
    end
    scope = scope.page(conditions[:page])
    scope
  }
  scope :by_tag_id, ->(tag_id) { joins(feed: :taggings).merge(Tagging.where(tag_id: tag_id)) }
end
