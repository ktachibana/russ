require 'open-uri'
require 'rss'

class RssSource < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true
  validates :url, presence: true, length: { maximum: 2048 }
  validates :title, presence: true, length: { maximum: 255 }
  validates :link_url, presence: true, length: { maximum: 2048 }
  validates :description, length: { maximum: 4096 }

  def self.by_url(url)
    open(url) do |rss_body|
      rss = RSS::Parser.parse(rss_body)
      return new do |m|
        m.url = url
        m.title = rss.channel.title
        m.description = rss.channel.description
        m.link_url = rss.channel.link
      end
    end
  end
end
