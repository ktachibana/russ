Vue.component 'tag-buttons',
  template: '#tag-buttons'
  data:
    tags: []
  methods:
    selectedTagNames: ->
      _.chain(@tags).filter((tag) -> tag.active ).map((tag) -> tag.name ).value()

  components:
    'tag-button' : Vue.extend
      template: '#tag-button'
      data:
        active: false
      methods:
        dispatchChanged: ->
          @$dispatch 'tag-changed', @$parent.selectedTagNames()

        select: ->
          _.each @$parent.tags, (tag) =>
            tag.active = (tag == @$data)
          @dispatchChanged()

        toggle: ->
          @active = !@active
          @dispatchChanged()

Vue.component 'item-panel',
  template: '#item-panel'
  computed:
    subscriptionPath: ->
      Routes.subscriptionPath(@feed.users_subscription)

if $('.root-controller.index-action').length
  new Vue
    el: '#main-content'
    data:
      items: []
      tags: []
      page: 1
      isLastPage: true

    methods:
      loadItems: ->
        ($.getJSON Routes.itemsPath(tag: @$.tagButtons.selectedTagNames(), page: @page)).then (result) =>
          @isLastPage = result.last_page
          result.items

      showMore: ->
        @page += 1
        @loadItems().then (items) =>
          @items = @items.concat(items)

    created: ->
      @$on 'tag-changed', ->
        @page = 1
        @loadItems().then (items) =>
          @items = items

      ($.getJSON Routes.rootPath()).then (data) =>
        @items = data.items.items
        @isLastPage = data.items.last_page
        @tags = data.tags
