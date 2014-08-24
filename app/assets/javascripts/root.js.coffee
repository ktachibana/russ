Vue.component 'item-panel',
  template: '#item-panel'
  computed:
    subscriptionPath: ->
      Routes.subscriptionPath(@feed.users_subscription)

if $('.root-controller.index-action').length
  vue = new Vue
    el: '#main-content'
    data:
      items: []
    methods:
      subscriptionPath: Routes.subscriptionPath
    created: ->
      ($.getJSON Routes.itemsPath()).then (data) =>
        @items = data
