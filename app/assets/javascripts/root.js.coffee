if $('.root-controller.index-action').length
  vue = new Vue
    el: '#main-content'
    data:
      items: []
    methods:
      subscriptionPath: Routes.subscriptionPath
    created: ->
      ($.getJSON '/items.json').then (data) =>
        @items = data
