# frozen_string_literal: true

class ItemsController < ApplicationController
  def index
    @items = Item.search(current_user, params)
  end
end
