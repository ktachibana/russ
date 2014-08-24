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

    methods:
      reloadItems: (params) ->
        ($.getJSON Routes.itemsPath(params)).then (data) =>
          @items = data

      selectedTagNames: ->
        _.chain(@tags).filter((tag) -> tag.active ).map((tag) -> tag.name ).value()

    created: ->
      @$on 'tag-changed', (selectedTagNames) ->
        @reloadItems(tag: selectedTagNames)

      ($.getJSON Routes.rootPath()).then (data) =>
        @items = data.items
        @tags = data.tags
