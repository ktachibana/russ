require 'open-uri'
require 'rss'
require 'rexml/document'

class Feed < ActiveRecord::Base
  has_many :items, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_one :latest_item, class_name: 'Item'
  acts_as_taggable

  accepts_nested_attributes_for :items

  validates :url, presence: true, length: { maximum: 2048 }
  validates :title, presence: true, length: { maximum: 255 }
  validates :link_url, presence: true, length: { maximum: 2048 }
  validates :description, length: { maximum: 4096 }

  scope :search, ->(conditions) {
    scope = self
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

        attributes = rss.items.map do |loaded_item|
          to_item_attributes(loaded_item)
        end
        self.items_attributes = attributes
      end
    rescue => e
      Rails.logger.error(e)
      nil # TODO エラーハンドリング
    end

    def to_item_attributes(parsed_item)
      guid = parsed_item.try(:guid).try(:content)

      item = guid && items.find_by(guid: guid)
      item ||= items.find_by(link: parsed_item.link)

      {
          link: parsed_item.link,
          title: parsed_item.title,
          guid: guid,
          published_at: parsed_item.date.try { |d| [d, Time.current].min },
          description: parsed_item.description
      }.tap do |attributes|
        attributes[:id] = item.id if item
      end
    end

    module ClassMethods
      def load_all!
        logger.info('start load_all!')
        find_each do |feed|
          sleep(5)
          feed.load!
          feed.save
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
        feed = Feed.create!(url: url, title: title, link_url: link_url)
        result << user.subscriptions.create!(feed: feed)
      else title
        outline.elements.each('outline') do |child|
          child_attrs = child.attributes
          feed_title = child_attrs['text'] || child_attrs['title']
          url = child_attrs['xmlUrl']
          link_url = child_attrs['htmlUrl']

          feed = Feed.create!(url: url, title: feed_title, link_url: link_url)
          result << user.subscriptions.create!(feed: feed, tag_list: [title])
        end
      end
    end
    result
  end
end
