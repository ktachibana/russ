Vue.component 'tag-buttons',
  template: '#tag-buttons'
  data: ->
    tags: []
    currentTags: []
  methods:
    inactivate: (tagName) ->
      @currentTags = _.without(@currentTags, tagName)
    activateOnly: (tagName) ->
      oldTags = @currentTags
      @currentTags = [tagName]
      !_.isEqual(@currentTags, oldTags)
    activate: (tagName) ->
      if @isActive(tagName)
        false
      else
        @currentTags.push(tagName)
        true
    isActive: (tagName) ->
      _.contains(@currentTags, tagName)

  components:
    'tag-button' : Vue.extend
      template: '#tag-button'
      inherit: true
      computed:
        isActive: ->
          @$parent.isActive(@name)
      methods:
        dispatchChanged: ->
          @$dispatch('tag-buttons-changed', @currentTags)

        select: ->
          if @$parent.activateOnly(@name)
            @dispatchChanged()

        toggle: ->
          if @isActive
            @$parent.inactivate(@name)
          else
            @$parent.activate(@name)
          @dispatchChanged()

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
        "#/#{@currentTagParams}"

      feedsPath: ->
        "#/feeds/#{@currentTagParams}"

    methods:
      updateTags: ->
        ($.getJSON Routes.tagsPath()).then (tags) =>
          @tags = tags

      setCurrentTags: (tags) ->
        newTags = _.sortBy tags, (tag) -> tag
        @currentTags = newTags


  Path.map('#/feeds/(:tags)').to () ->
    app.setCurrentTags @params.tags?.split(',') || []
    if app.currentPage != 'feeds-page'
      app.currentPage = 'feeds-page'
    else
      app.$broadcast 'current-tags-changed'

  Path.map('#/subscriptions/:id/edit').to () ->
    app.params = { id: @params.id }
    app.currentPage = 'edit-subscription-page'

  Path.map('#/subscriptions/new/:feedUrl').to () ->
    app.params = { feedUrl: @params.feedUrl }
    app.currentPage = 'edit-subscription-page'

  Path.map('#/items(/:tags)').to () ->
    app.setCurrentTags @params.tags?.split(',') || []
    if app.currentPage != 'root-page'
      app.currentPage = 'root-page'
    else
      app.$broadcast 'current-tags-changed'

  Path.root '#/items'
  $ ->
    Path.listen()