class FeedsController < ApplicationController
  def new
    @feed = Feed.by_url(params[:url])
  end

  def create
    @feed = current_user.feeds.build(feeds_params)

    if @feed.save
      redirect_to root_url
    else
      render :new
    end
  end

  def update_all
    current_user.feeds.find_each do |feed|
      feed.load!
    end
    redirect_to root_url
  end

  def import
    imported_feed = Feed.import!(current_user, params[:file].read)
    imported_feed.each do |feed|
      sleep(2)
      feed.load!
    end
    redirect_to root_url
  end

private
  def feeds_params
    params.require(:feed).permit(:url, :title, :link_url, :description)
  end
end