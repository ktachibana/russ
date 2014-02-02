class MigrateFeedToSubscription < ActiveRecord::Migration
  class Subscription < ActiveRecord::Base; end
  class Feed < ActiveRecord::Base; end

  class Tagging < ActiveRecord::Base
    belongs_to :taggable, polymorphic: true
  end

  def up
    ActiveRecord::Base.transaction do
      Tagging.find_each do |tagging|
        feed = Feed.find(tagging.taggable_id)
        subscription = Subscription.find_or_create_by(user_id: feed.user_id, feed_id: feed.id)
        tagging.update_attributes(taggable_id: subscription.id, taggable_type: 'Subscription')
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
