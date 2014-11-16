Vue.component 'item-panel',
  template: '#item-panel'
  computed:
    feedPath: ->
      Routes.feedPath(@feed)

Vue.component 'root-page',
  template: '#root-page'
  inherit: true
  data: ->
    items: []
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

    onTagChanged: (newTags) ->
      @currentTags = newTags
      Router.setCurrentPath(@currentPath)
      @page = 1
      @loadItems().then (items) =>
        @items = items
      null

  compiled: () ->
    @loadItems().then (items) =>
      @items = items

  created: ->
    @$on 'tag-changed', @onTagChanged
