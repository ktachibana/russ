class Item < ActiveRecord::Base
  belongs_to :feed

  default_scope { order(published_at: :desc) }
  scope :user, -> (user) { joins(feed: :subscriptions).includes(feed: :subscriptions).merge(Subscription.where(user_id: user.id)) }
  scope :search, lambda { |conditions|
    scope = self
    conditions[:tag].presence.try do |tags|
      scope = scope.joins(feed: :subscriptions).merge(Subscription.tagged_with(tags))
    end
    scope = scope.page(conditions[:page])
    scope
  }
end
