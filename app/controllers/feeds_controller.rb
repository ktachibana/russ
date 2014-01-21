class FeedsController < ApplicationController
  def index
    @feeds = owned_feeds.includes(:latest_item, :tags).order(:id).search(params)
  end

  def show
    @feed = owned_feeds.find(params[:id])
    @items = @feed.items.page(params[:page])
  end

  def new
    url = params[:url]
    owned_feeds.find_by(url: url).try do |feed|
      return redirect_to(feed, notice: I18n.t('messages.feed_already_registed', url: url))
    end
    @feed = Feed.by_url(url)
  end

  def create
    @feed = owned_feeds.build(feed_params)

    if @feed.save
      @feed.load!
      redirect_to root_url
    else
      render :new
    end
  end

  def update
    @feed = owned_feeds.find(params[:id])
    @feed.update_attributes!(feed_params)
    respond_to do |format|
      format.js
      format.html { redirect_to action: :index }
    end
  end

  def import
    if params[:file].blank?
      flash[:alert] = 'Select OPML file.'
      return redirect_to(upload_feeds_path)
    end

    Feed.import!(current_user, params[:file].read)
    redirect_to root_url
  end

  def destroy
    Feed.destroy(params[:id])
    redirect_to(Feed)
  end

  private
  def owned_feeds
    current_user.feeds
  end

  def feed_params
    params.require(:feed).permit(:url, :title, :link_url, :description, :tag_list)
  end
end
