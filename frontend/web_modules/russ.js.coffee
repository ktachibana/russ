$ = require('jquery');
Vue = require('vue');
_ = require('underscore');
Routes = require('app/routes');
Path = require('pathjs').pathjs;

if $('.vue-app').length
  app = new Vue
    el: '#main-content'
    data:
      currentPage: null
      currentTags: []
      tags: []
      params: {}

    compiled: () ->
      @updateTags()

    computed:
      currentTagParams: ->
        tags = _.map @currentTags, (tag) ->
          encodeURIComponent(tag)
        tags.join(',')

      rootPath: ->
        "#/items/#{@currentTagParams}"

      feedsPath: ->
        "#/feeds/#{@currentTagParams}"

    methods:
      updateTags: ->
        ($.getJSON Routes.tagsPath()).then (tags) =>
          @tags = tags

      setCurrentTags: (tags) ->
        newTags = tags.sort()
        @currentTags = newTags


  Path.map('#/feeds/(:tags)').to () ->
    encodedTags = (@params.tags || null)?.split(',') || []
    tags = _.map encodedTags, (tag) -> decodeURIComponent(tag)
    app.setCurrentTags tags
    if app.currentPage != 'feeds-page'
      app.currentPage = 'feeds-page'
    else
      app.$broadcast 'current-tags-changed'

  Path.map('#/subscriptions/new/:feedUrl').to () ->
    url = @params.feedUrl
    url = atob(url.replace('-', '+').replace('_', '/'))
    app.params = { feedUrl: url }
    app.currentPage = 'subscription-page'

  Path.map('#/subscriptions/:id').to () ->
    app.params = { id: @params.id }
    app.currentPage = 'subscription-page'

  Path.map('#/items/(:tags)').to () ->
    encodedTags = (@params.tags || null)?.split(',') || []
    tags = _.map encodedTags, (tag) -> decodeURIComponent(tag)
    app.setCurrentTags tags
    if app.currentPage != 'root-page'
      app.currentPage = 'root-page'
    else
      app.$broadcast 'current-tags-changed'

  Path.root '#/items/'
  $ ->
    Path.listen()
