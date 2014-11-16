Vue.component 'item-panel',
  template: '#item-panel'
  computed:
    feedPath: ->
      Routes.feedPath(@feed)

if $('.root-controller.index-action').length
  vue = new Vue
    el: '#main-content'
    data:
      items: []
      tags: []
      currentTags: []
      page: 1
      isLastPage: true

    computed:
      currentPath: ->
        '/' + @currentTags.join(',')

    methods:
      init: (tags) ->
        @currentTags = tags
        ($.getJSON Routes.rootPath(tag: @currentTags)).then (data) =>
          @items = data.items.items
          @isLastPage = data.items.last_page
          @tags = data.tags

      loadItems: ->
        ($.getJSON Routes.itemsPath(tag: @currentTags, page: @page)).then (result) =>
          @isLastPage = result.last_page
          result.items

      showMore: ->
        @page += 1
        @loadItems().then (items) =>
          @items = @items.concat(items)

      onTagChanged: (newTags) ->
        @currentTags = newTags
        Router.setCurrentPath(@currentPath)
        @page = 1
        @loadItems().then (items) =>
          @items = items
        null

    created: ->
      @$on 'tag-changed', @onTagChanged

  Router.on '/:tags?', (tagsParam) ->
    vue.init(tagsParam?.split(',') || [])

  Router.dispatch()
