Vue = require('vue');
$ = require('jquery');
Routes = require('./app/routes');
_ = require('underscore');

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
      tags = _.map newTags, (tag) -> encodeURIComponent(tag)
      location.hash = "#/feeds/#{tags.join(',')}"

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
  inherit: true
  computed:
    feedPath: ->
      Routes.feedPath(@feed)

    subscriptionPath: ->
      Routes.subscriptionPath(@)

    classList: ->
      ['form', "_#{@id}"]

    href: ->
      "#/subscriptions/#{@id}"
