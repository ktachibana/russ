if $('.root-controller.index-action').length
  vue = new Vue
    el: '#main-content'
    data:
      items: []
    methods:
      subscription_path: Routes.subscription_path
    created: ->
      ($.getJSON '/items.json').then (data) =>
        @items = data
