Vue.component 'feeds-page',
  template: '#feeds-page'
  inherit: true
  data: ->
    subscriptions: []
    page: 1
    isLastPage: true

  methods:
    readFeeds: ->
      ($.getJSON(Routes.feedsPath(), tag: @$parent.currentTags, page: @page)).then (data) =>
        @isLastPage = data.lastPage
        data.subscriptions

    loadFeeds: ->
      @page = 1
      @readFeeds().then (subscriptions) =>
        @subscriptions = subscriptions

    onTagButtonsChanged: (newTags) ->
      location.hash = "#/feeds/#{newTags.join(',')}"

    onCurrentTagsChanged: ->
      @loadFeeds()

    showMore: ->
      @page += 1
      @readFeeds().then (subscriptions) =>
        @subscriptions = @subscriptions.concat(subscriptions)

  compiled: ->
    @loadFeeds()

  created: ->
    @$on 'tag-buttons-changed', @onTagButtonsChanged
    @$on 'current-tags-changed', @onCurrentTagsChanged

Vue.component 'subscription-row',
  template: '#subscription-row',
  computed:
    feedPath: ->
      Routes.feedPath(@feed)
    subscriptionPath: ->
      Routes.subscriptionPath(this)
    classList: ->
      "_#{@id}"
