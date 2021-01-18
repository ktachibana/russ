# frozen_string_literal: true

require 'open-uri'
require 'rss'

class Feed < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_one :latest_item, class_name: 'Item'

  accepts_nested_attributes_for :items

  validates :url, presence: true, length: { maximum: 2048 }
  validates :title, presence: true, length: { maximum: 255 }
  validates :link_url, presence: true, length: { maximum: 2048 }
  validates :description, length: { maximum: 4096 }

  attr_accessor :users_subscription

  module FileLoadable
    extend ActiveSupport::Concern

    def update_by_rss!(rss)
      self.title = rss.channel.title
      self.description = rss.channel.description
      self.link_url = rss.channel.link

      attributes = rss.items.map do |loaded_item|
        to_item_attributes(loaded_item)
      end
      self.items_attributes = attributes
    end

    def update_by_atom!(atom)
      self.title = atom.title.content
      self.description = atom.subtitle.try(:content)
      self.link_url = atom.links.find { |link| link.rel == 'alternate' }.try(:href)
      self.link_url ||= atom.links[0].try(:href) || url

      guid_id_map = items.each_with_object({}) do |item, hash|
        hash[item.guid] = item.id
      end
      attributes = atom.items.map do |item|
        {}.tap do |result|
          guid = item.id.try(:content) || result[:link]
          result[:guid] = guid
          guid_id_map[guid].try { |id| result[:id] = id }
          result[:title] = item.title.content
          result[:link] = item.link.href
          result[:published_at] = item.updated.content
          result[:description] = item.content.content
        end
      end

      self.items_attributes = attributes
    end

    def load!
      self.class.load_rss(url) do |rss|
        case rss.feed_type
        when 'atom'
          update_by_atom!(rss)
        else
          update_by_rss!(rss)
        end
        self.loaded_at = Time.current
        resolve_relative_url!
      end
    rescue StandardError => e
      Rails.logger.error(url: url, message: e.message)
      nil # TODO: エラーハンドリング
    end

    def resolve_relative_url!
      return if url.blank?

      self.link_url = URI.join(url, link_url).to_s if link_url.present?
      items.each do |item|
        item.link = URI.join(url, item.link) if item.link.present?
      end
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
        published_at: parsed_item.date,
        description: parsed_item.description
      }
    end

    def find_existing_item(guid, parsed_item)
      (guid && items.find_by(guid: guid)) || items.find_by(link: parsed_item.link)
    end

    module ClassMethods
      def load_all!(count: 75)
        logger.info('start load_all!')

        order(loaded_at: :asc).limit(count).each do |feed|
          logger.info "Feed#load! url: #{feed.url}"

          sleep(1)
          feed.load!
          feed.save
        end
        logger.info('load_all! completed.')
      end

      def load_rss(url)
        URI.open(url) do |rss_body|
          return yield RSS::Parser.parse(rss_body)
        end
      end
    end
  end
  include FileLoadable
end
