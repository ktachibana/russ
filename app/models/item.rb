class Item < ActiveRecord::Base
  belongs_to :rss_source

  validates :rss_source_id, presence: true
end
