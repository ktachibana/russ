Vue.component 'feeds-page',
  template: '#feeds-page'
  inherit: true
  data: ->
    currentTags: []
    subscriptions: []
  compiled: ->
    ($.getJSON Routes.feedsPath()).then (data) =>
      console.log data
      @subscriptions = data.subscriptions

Vue.component 'subscription-row',
  template: '#subscription-row',
  computed:
    feedPath: ->
      Routes.feedPath(@feed)
    subscriptionPath: ->
      Routes.subscriptionPath(this)
    classList: ->
      "_#{@id}"
