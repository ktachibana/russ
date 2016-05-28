Vue = require('vue');
moment = require('moment')

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
    publishedAtMoment: ->
      moment(@publishedAt)
  methods:
    showAll: ->
      @shorten = false
