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
      '/' + @currentTagParams

  methods:
    loadItems: ->
      ($.getJSON Routes.itemsPath(tag: @$parent.currentTags, page: @page)).then (result) =>
        @isLastPage = result.last_page
        result.items

    showMore: ->
      @page += 1
      @loadItems().then (items) =>
        @items = @items.concat(items)

    onTagButtonsChanged: (newTags) ->
      location.hash = "#/#{newTags.join(',')}"

    onCurrentTagsChanged: ->
      @page = 1
      @loadItems().then (items) =>
        @items = items
      null

  compiled: () ->
    @loadItems().then (items) =>
      @items = items

  created: ->
    @$on 'tag-buttons-changed', @onTagButtonsChanged
    @$on 'current-tags-changed', @onCurrentTagsChanged
