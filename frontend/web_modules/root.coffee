Vue = require('vue');
$ = require('jquery');
_ = require('underscore');
Routes = require('app/routes');

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
        @isLastPage = result.lastPage
        result.items

    showMore: ->
      @page += 1
      @updateItems().then (items) =>
        @items = @items.concat(items)

    onTagButtonsChanged: (newTags) ->
      tags = _.map newTags, (tag) -> encodeURIComponent(tag)
      location.hash = "#/items/#{tags.join(',')}"

    onCurrentTagsChanged: ->
      @page = 1
      @updateItems().then (items) =>
        @items = items
      null

  compiled: () ->
    @updateItems().then (items) =>
      @items = items

  created: ->
    @$on 'tag-buttons-changed', @onTagButtonsChanged
    @$on 'current-tags-changed', @onCurrentTagsChanged
