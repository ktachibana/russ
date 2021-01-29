# frozen_string_literal: true

module Feeds
  class Atom
    def initialize(atom)
      @atom = atom
    end

    attr_reader :atom

    def title
      atom.title.content
    end

    def description
      atom.subtitle&.content
    end

    def link
      alternate_link || first_link
    end

    def alternate_link
      atom.links.find { |link| link.rel == 'alternate' }&.href
    end

    def first_link
      atom.links[0]&.href
    end

    def items
      atom.items.map { |item| Item.new(item) }
    end

    class Item
      def initialize(item)
        @item = item
      end

      attr_reader :item

      def guid
        item.id&.content
      end

      def title
        item.title.content
      end

      def link
        item.link.href
      end

      def date
        item.updated.content
      end

      def description
        item.content.content
      end
    end
  end
end
