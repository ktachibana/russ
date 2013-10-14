class FeedsController < ApplicationController
  def index
    @feeds = current_user.feeds.includes(:taggings, :items).page(params[:page])
  end

  def new
    @feed = Feed.by_url(params[:url])
  end

  def create
    @feed = current_user.feeds.build(feeds_params)
    @feed.taggings.each do |tagging|
      tagging.mark_for_destruction if tagging.tag_id.blank?
    end

    if @feed.save
      @feed.load!
      redirect_to root_url
    else
      render :new
    end
  end

  def update
    @feed = current_user.feeds.find(params[:id])
    @feed.assign_attributes(feeds_params)
    @feed.taggings.each do |tagging|
      tagging.mark_for_destruction if tagging.tag_id.blank?
    end
    @feed.save!
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

private
  def feeds_params
    params.require(:feed).permit(:url, :title, :link_url, :description, taggings_attributes: %i[id tag_id])
  end
end
