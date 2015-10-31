Vue.component 'item-panel',
  template: '#item-panel',
  paramAttributes: ['hidefeed'],
  compiled: ->
    @hidefeed = @hidefeed?
  computed:
    subscriptionPath: ->
      "#/subscriptions/#{@feed.usersSubscription.id}"
    publishedAtDate: ->
      new Date(@publishedAt)
