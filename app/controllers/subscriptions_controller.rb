# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  def show
    @subscription = owned_subscriptions.preload(:feed).find(params[:id])
    @items = @subscription.feed.items.page(params[:page])
  end

  def new
    url = params.require(:url)
    @subscription = owned_subscriptions.prefetch(url)
    @items = @subscription.feed.items.first(Kaminari.config.default_per_page)
    render :show
  rescue Subscription::FeedNotFound
    flash['alert'] = I18n.t('messages.feed_not_found')
    render json: { type: 'feedNotFound' }, status: :unprocessable_entity
  rescue Subscription::AlreadySubscribed => e
    flash[:notice] = I18n.t('messages.feed_already_registered', url: e.subscription.feed.url)
    render json: { id: e.subscription.id }
  end

  def create
    @subscription = owned_subscriptions.build(params_for_create)
    @subscription.subscribe!
    render json: { id: @subscription.id }
  end

  def update
    @subscription = owned_subscriptions.find(params[:id])
    @subscription.update!(params_for_update)
    render json: { id: @subscription.id }
  end

  def import
    opml_file = params[:file]
    return render json: { error: 'Select OPML file.' }, status: :unprocessable_entity if opml_file.blank?

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

  def params_for_create
    subscription_params.permit(:title, :tag_list, :hide_default, feed_attributes: [:url])
  end

  def params_for_update
    subscription_params.permit(:title, :tag_list, :hide_default)
  end

  def owned_subscriptions
    current_user.subscriptions
  end

  def subscription_params
    params.require(:subscription)
  end
end
