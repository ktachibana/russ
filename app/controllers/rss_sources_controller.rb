class RssSourcesController < ApplicationController
  def new
    @rss_source = RssSource.by_url(params[:url])
  end

  def create
    @rss_source = current_user.rss_sources.build(rss_source_params)

    if @rss_source.save
      redirect_to root_url
    else
      render :new
    end
  end

  def update_all
    current_user.rss_sources.find_each do |source|
      source.load!
    end
    redirect_to root_url
  end

  def import
    imported_sources = RssSource.import!(current_user, params[:file].read)
    imported_sources.each(&:load!)
    redirect_to root_url
  end

private
  def rss_source_params
    params.require(:rss_source).permit(:url, :title, :link_url, :description)
  end
end
