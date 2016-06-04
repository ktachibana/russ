class SubscriptionsController < ApplicationController
  def show
    @subscription = owned_subscriptions.preload(:feed).find(params[:id])
    @items = @subscription.feed.items.page(params[:page])
  end

  def new
    url = params[:url]
    respond_to do |format|
      format.json do
        owned_subscriptions.joins(:feed).merge(Feed.where(url: url)).first.try do |subscription|
          return redirect_to(root_path, notice: I18n.t('messages.feed_already_registed', url: url))
        end
        @feed = Feed.find_or_initialize_by(url: url)
        @feed.load! if @feed.new_record?
        @subscription = current_user.subscriptions.build(feed: @feed)
      end
      format.html do
        url = Feedbag.find(url)[0]
        return redirect_to(root_path, alert: I18n.t('messages.feed_not_found')) unless url
        encoded = Base64.urlsafe_encode64(url)
        redirect_to(root_path(anchor: "/subscriptions/new/#{encoded}"))
      end
    end
  end

  # JSON API
  def create
    @subscription = owned_subscriptions.build(subscription_params.permit(:title, :tag_list, feed_attributes: [:url]))
    @subscription.subscribe!
    render json: { id: @subscription.id }
  end

  def update
    @subscription = owned_subscriptions.find(params[:id])
    @subscription.update_attributes!(subscription_params.permit(:title, :tag_list))
    respond_to do |format|
      format.json { render json: { id: @subscription.id } }
      format.js
      format.html { redirect_to(feeds_path) }
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
    render_json_ok
  end

  private

  def owned_subscriptions
    current_user.subscriptions
  end

  def subscription_params
    params.require(:subscription)
  end
end
