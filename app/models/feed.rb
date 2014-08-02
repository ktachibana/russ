require 'open-uri'
require 'rss'
require 'rexml/document'

class Feed < ActiveRecord::Base
  has_many :items, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_one :users_subscription, class_name: 'Subscription'
  has_one :latest_item, class_name: 'Item'
  acts_as_taggable

  accepts_nested_attributes_for :items

  validates :url, presence: true, length: { maximum: 2048 }
  validates :title, presence: true, length: { maximum: 255 }
  validates :link_url, presence: true, length: { maximum: 2048 }
  validates :description, length: { maximum: 4096 }

  scope :search, lambda { |conditions|
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
      nil # TODO: エラーハンドリング
    end

    def to_item_attributes(parsed_item)
      guid = parsed_item.try(:guid).try(:content)

      result = parsed_item_attributes(guid, parsed_item)
      find_existing_item(guid, parsed_item).try do |item|
        result[:id] = item.id
      end
      result
    end

    def parsed_item_attributes(guid, parsed_item)
      {
        link: parsed_item.link,
        title: parsed_item.title,
        guid: guid,
        published_at: parsed_item.date.try { |d| [d, Time.current].min },
        description: parsed_item.description
      }
    end

    def find_existing_item(guid, parsed_item)
      (guid && items.find_by(guid: guid)) || items.find_by(link: parsed_item.link)
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
end
