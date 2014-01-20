class Item < ActiveRecord::Base
  belongs_to :feed

  validates :feed_id, presence: true

  default_scope { order(published_at: :desc) }
  scope :user, ->(user) { joins(:feed).includes(:feed).merge(Feed.where(user_id: user.id)) }
  scope :search, ->(conditions) {
    scope = self
    conditions[:tag].presence.try do |tags|
      scope = scope.joins(:feed).merge(Feed.tagged_with(tags))
    end
    scope = scope.page(conditions[:page])
    scope
  }
end
