json.partial! 'subscription', subscription: users_subscription
json.call(users_subscription, :user_title)
