class SubscriptionsController < ApplicationController
  def show
    @subscription = owned_subscriptions.preload(:feed).find(params[:id])
    @items = @subscription.feed.items.page(params[:page])
  end

  def new
    url = params[:url]
    owned_subscriptions.joins(:feed).merge(Feed.where(url: url)).first.try do |subscription|
      flash[:notice] = I18n.t('messages.feed_already_registed', url: url)
      return render json: { id: subscription.id }
    end

    feed_url = Feedbag.find(url)[0]
    unless feed_url
      flash['alert'] = I18n.t('messages.feed_not_found')
      return render json: { type: 'feedNotFound' }, status: :unprocessable_entity
    end

    @feed = Feed.find_or_initialize_by(url: feed_url)
    @feed.load! if @feed.new_record?
    @subscription = current_user.subscriptions.build(feed: @feed)
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
      return render json: { error: 'Select OPML file.' }, status: :unprocessable_entity
    end

    OPML.import!(opml_file.tempfile, current_user)

    head :ok
  rescue OPML::InvalidFormat
    render json: { error: 'Invalid file format.' }, status: :unprocessable_entity
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
