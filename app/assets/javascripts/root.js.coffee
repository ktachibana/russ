Vue.component 'tag-buttons',
  template: '#tag-buttons'
  data:
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
      computed:
        isActive: ->
          @$parent.isActive(@name)
      methods:
        dispatchChanged: ->
          @$dispatch('tag-changed')

        select: ->
          if @$parent.activateOnly(@name)
            @dispatchChanged()

        toggle: ->
          if @isActive
            @$parent.inactivate(@name)
          else
            @$parent.activate(@name)
          @dispatchChanged()

Vue.component 'item-panel',
  template: '#item-panel'
  computed:
    subscriptionPath: ->
      Routes.subscriptionPath(@feed.users_subscription)

rootAction = (tags) ->
  new Vue
    el: '#main-content'
    data:
      items: []
      tags: []
      currentTags: tags
      page: 1
      isLastPage: true

    computed:
      currentPath: ->
        '/' + @currentTags.join(',')

    methods:
      loadItems: ->
        ($.getJSON Routes.itemsPath(tag: @currentTags, page: @page)).then (result) =>
          @isLastPage = result.last_page
          result.items

      showMore: ->
        @page += 1
        @loadItems().then (items) =>
          @items = @items.concat(items)

    created: ->
      @$on 'tag-changed', ->
        Router.setCurrentPath(@currentPath)
        @page = 1
        @loadItems().then (items) =>
          @items = items

      ($.getJSON Routes.rootPath(tag: @currentTags)).then (data) =>
        @items = data.items.items
        @isLastPage = data.items.last_page
        @tags = data.tags

if $('.root-controller.index-action').length
  Router.on '/', () -> rootAction([])
  Router.on '/:tags', (tagsParam) -> rootAction(tagsParam.split(','))

  Router.dispatch()
