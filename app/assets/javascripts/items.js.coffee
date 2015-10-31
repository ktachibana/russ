Vue.component 'item-panel',
  template: '#item-panel',
  paramAttributes: ['hidefeed'],
  data: ->
    shorten: true
  compiled: ->
    @hidefeed = @hidefeed?
  computed:
    subscriptionPath: ->
      "#/subscriptions/#{@feed.usersSubscription.id}"
    publishedAtDate: ->
      new Date(@publishedAt)
  methods:
    showAll: ->
      @shorten = false
