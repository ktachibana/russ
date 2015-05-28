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
    app.setCurrentTags @params.tags?.split(',') || []
    if app.currentPage != 'feeds-page'
      app.currentPage = 'feeds-page'
    else
      app.$broadcast 'current-tags-changed'

  Path.map('#/subscriptions/new/:feedUrl').to () ->
    app.params = { feedUrl: atob(@params.feedUrl) }
    app.currentPage = 'subscription-page'

  Path.map('#/subscriptions/:id').to () ->
    app.params = { id: @params.id }
    app.currentPage = 'subscription-page'

  Path.map('#/items/(:tags)').to () ->
    app.setCurrentTags (@params.tags || null)?.split(',') || []
    if app.currentPage != 'root-page'
      app.currentPage = 'root-page'
    else
      app.$broadcast 'current-tags-changed'

  Path.root '#/items/'
  $ ->
    Path.listen()
