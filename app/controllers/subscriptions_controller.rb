class SubscriptionsController < ApplicationController
  def show
    @subscription = owned_subscriptions.preload(:feed).find(params[:id])
    @items = @subscription.feed.items.page(params[:page])
  end

  def new
    url = params[:url]
    render_if_already_registed(url) && return

    feed_url = Feedbag.find(url)[0]
    unless feed_url
      flash['alert'] = I18n.t('messages.feed_not_found')
      return render json: { type: 'feedNotFound' }, status: :unprocessable_entity
    end
    render_if_already_registed(feed_url) && return

    @feed = Feed.find_or_initialize_by(url: feed_url)
    @feed.load! if @feed.new_record?
    @subscription = current_user.subscriptions.build(feed: @feed)
  end

  def render_if_already_registed(url)
    owned_subscriptions.url(url).first.try! do |subscription|
      flash[:notice] = I18n.t('messages.feed_already_registed', url: url)
      render json: { id: subscription.id }
      return true
    end
    false
  end
  private :render_if_already_registed

  def create
    @subscription = owned_subscriptions.build(subscription_params.permit(:title, :tag_list, feed_attributes: [:url]))
    @subscription.subscribe!
    render json: { id: @subscription.id }
  end

  def update
    @subscription = owned_subscriptions.find(params[:id])
    @subscription.update!(subscription_params.permit(:title, :tag_list))
    render json: { id: @subscription.id }
  end

  def import
    opml_file = params[:file]
    if opml_file.blank?
      return render json: { error: 'Select OPML file.' }, status: :unprocessable_entity
    end

    OPML.import!(opml_file.tempfile, current_user)

    render_json_ok
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
