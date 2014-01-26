require 'open-uri'
require 'rss'
require 'rexml/document'

class Feed < ActiveRecord::Base
  belongs_to :user
  has_many :items, dependent: :destroy
  has_one :latest_item, class_name: 'Item'
  acts_as_taggable

  validates :user_id, presence: true
  validates :url, presence: true, length: { maximum: 2048 }
  validates :title, presence: true, length: { maximum: 255 }
  validates :link_url, presence: true, length: { maximum: 2048 }
  validates :description, length: { maximum: 4096 }

  scope :search, ->(conditions) {
    scope = all
    conditions[:tag].presence.try do |tag_names|
      scope = scope.tagged_with(tag_names)
    end
    scope = scope.page(conditions[:page])
    scope
  }

  def tags_string
    tags.map(&:name).join(', ')
  end

  module FileLoadable
    extend ActiveSupport::Concern

    def update_by_rss!(rss)
      self.title = rss.channel.title
      self.description = rss.channel.description
      self.link_url = rss.channel.link
    end

    def load!
      self.class.load_rss(url) do |rss|
        update_by_rss!(rss)
        save

        rss.items.each do |loaded_item|
          guid = loaded_item.try(:guid).try(:content)

          item = guid && items.find_by(guid: guid)
          item ||= items.find_by(link: loaded_item.link)
          item ||= items.build
          item.link = loaded_item.link
          item.title = loaded_item.title
          item.guid = guid
          item.published_at = loaded_item.date
          item.description = loaded_item.description
          item.save
        end
      end
    rescue => e
      Rails.logger.error(e)
      nil # TODO エラーハンドリング
    end

    module ClassMethods
      def load_by_url(url)
        load_rss(url) do |rss|
          new do |m|
            m.url = url
            m.update_by_rss!(rss)
          end
        end
      end

      def load_all!
        logger.info('start load_all!')
        find_each do |feed|
          sleep(5)
          feed.load!
        end
      end

      def load_rss(url)
        open(url) do |rss_body|
          return yield RSS::Parser.parse(rss_body)
        end
      end
    end
  end
  include FileLoadable

  def self.import!(user, opml)
    doc = REXML::Document.new(opml)

    result = []
    doc.elements.each('opml/body/outline') do |outline|
      attrs = outline.attributes
      title = attrs['text'] || attrs['title']
      url = attrs['xmlUrl']
      link_url = attrs['htmlUrl']

      if url && title
        result << user.feeds.create!(url: url, title: title, link_url: link_url)
      else title
        outline.elements.each('outline') do |child|
          child_attrs = child.attributes
          feed_title = child_attrs['text'] || child_attrs['title']
          url = child_attrs['xmlUrl']
          link_url = child_attrs['htmlUrl']
          feed = user.feeds.create!(url: url, title: feed_title, link_url: link_url, tag_list: [title])
          result << feed
        end
      end
    end
    result
  end
end
