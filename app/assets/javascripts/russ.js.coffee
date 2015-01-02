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
          @$dispatch('tag-changed', @currentTags)

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
    compiled: () ->
      ($.getJSON Routes.tagsPath()).then (tags) =>
        @tags = tags

  Path.map('#/feeds/(:tags)').to () ->
    app.currentTags = @params['tags']?.split(',') || []
    app.currentPage = 'feeds-page'

  Path.map('#/(:tags)').to () ->
    app.currentTags = @params['tags']?.split(',') || []
    app.currentPage = 'root-page'

  Path.root '#/'
  Path.listen()
