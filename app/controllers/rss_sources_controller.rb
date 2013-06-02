class RssSourcesController < ApplicationController
  before_filter :authenticate_user!

  def new
    @rss_source = RssSource.by_url(params[:url])
  end

  def create
    @rss_source = current_user.rss_sources.build(rss_source_params)

    if @rss_source.save
      redirect_to(root_url)
    else
      render :new
    end
  end

private
  def rss_source_params
    params.require(:rss_source).permit(:url, :title, :link_url, :description)
  end
end
