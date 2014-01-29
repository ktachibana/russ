require 'open-uri'
require 'rss'
require 'rexml/document'

class Feed < ActiveRecord::Base
  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_one :latest_item, class_name: 'Item'
  acts_as_taggable

  accepts_nested_attributes_for :items

  validates :user_id, presence: true
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
          guid = loaded_item.try(:guid).try(:content)

          item = guid && items.find_by(guid: guid)
          item ||= items.find_by(link: loaded_item.link)
          {
            link: loaded_item.link,
            title: loaded_item.title,
            guid: guid,
            published_at: loaded_item.date,
            description: loaded_item.description
          }.tap do |attributes|
            attributes[:id] = item.id if item
          end
        end
        self.items_attributes = attributes
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
        feed = Feed.create!(url: url, title: title, link_url: link_url, user: user)
        result << user.subscriptions.create!(feed: feed)
      else title
        outline.elements.each('outline') do |child|
          child_attrs = child.attributes
          feed_title = child_attrs['text'] || child_attrs['title']
          url = child_attrs['xmlUrl']
          link_url = child_attrs['htmlUrl']
          feed = Feed.create!(url: url, title: feed_title, link_url: link_url, user: user)
          result << user.subscriptions.create!(feed: feed, tag_list: [title])
        end
      end
    end
    result
  end
end
