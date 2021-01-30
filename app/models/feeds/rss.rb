# frozen_string_literal: true

module Feeds
  class Rss
    def initialize(rss)
      @rss = rss
    end

    def channel
      @rss.channel
    end

    delegate :title, :description, :link, to: :channel

    def items
      @rss.items.map { |item| Item.new(item) }
    end

    class Item
      def initialize(item)
        @item = item
      end

      attr_reader :item

      delegate :title, :link, :date, :description, to: :item

      def guid
        # RDF形式だと #guid が無いので #try を使う
        item.try(:guid)&.content
      end
    end
  end
end
