class SubscriptionsController < ApplicationController
  def index
    @subscriptions = owned_subscriptions.includes({ feed: :latest_item }, :tags).order(:id).search(params)
  end

  def show
    @subscription = owned_subscriptions.includes(feed: :items).find(params[:id])
    @items = @subscription.feed.items.page(params[:page])
  end

  def new
    url = params[:url]
    owned_subscriptions.joins(:feed).merge(Feed.where(url: url)).first.try do |subscription|
      return redirect_to(subscription, notice: I18n.t('messages.feed_already_registed', url: url))
    end
    feed = Feed.find_or_initialize_by(url: url)
    feed.load! if feed.new_record?
    @subscription = current_user.subscriptions.build(feed: feed)
  end

  def create
    @subscription = owned_subscriptions.build(subscription_params.permit(:title, :tag_list, feed_attributes: [:url]))
    if @subscription.subscribe
      redirect_to root_url
    else
      render :new
    end
  end

  def update
    @subscription = owned_subscriptions.find(params[:id])
    @subscription.update_attributes!(subscription_params.permit(:title, :tag_list))
    respond_to do |format|
      format.js
      format.html { redirect_to action: :index }
    end
  end

  def import
    opml_file = params[:file]
    if opml_file.blank?
      flash[:alert] = 'Select OPML file.'
      return redirect_to(upload_subscriptions_path)
    end

    OPML.import!(opml_file, current_user)

    redirect_to root_url
  end

  def destroy
    Subscription.destroy(params[:id])
    redirect_to(Subscription)
  end

  private

  def owned_subscriptions
    current_user.subscriptions
  end

  def subscription_params
    params.require(:subscription)
  end
end
