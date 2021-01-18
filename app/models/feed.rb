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
      # エラーで更新できなくてもloaded_atは更新しないと、.load_all!で常に最初の処理対象になってしまう
      self.loaded_at = Time.current

      self.class.load_rss(url) do |rss|
        case rss.feed_type
        when 'atom'
          update_by_atom!(rss)
        else
          update_by_rss!(rss)
        end
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
      def load_all!(timeout: 10.minutes, interval_seconds: 1, before_feed: ->(_) {}, after_feed: ->(_) {})
        logger.info('start load_all!')

        with_time_limit(timeout) do |throw_if_timed_out|
          order(loaded_at: :asc).each do |feed|
            before_feed.call(feed)

            throw_if_timed_out.call

            logger.info "Feed#load! url: #{feed.url}"

            sleep(interval_seconds)
            feed.load!
            feed.save

            after_feed.call(feed)
          end
        end
        logger.info('load_all! completed.')
      end

      def with_time_limit(duration)
        ends_at = Time.current + duration
        throw_if_timeout = -> { throw :timeout if ends_at.past? }

        catch :timeout do
          yield throw_if_timeout
        end
      end

      def load_rss(url)
        connection = Faraday.new do |c|
          c.use FaradayMiddleware::FollowRedirects
          c.options.timeout = 5
        end
        response = connection.get(url)
        yield RSS::Parser.parse(response.body)
      end
    end
  end
  include FileLoadable
end
