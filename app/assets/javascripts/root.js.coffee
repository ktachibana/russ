if $('.root-controller.index-action').length
  vue = new Vue
    el: '#main-content'
    data:
      items: []
    created: ->
      ($.getJSON '/items.json').then (data) =>
        @items = data
