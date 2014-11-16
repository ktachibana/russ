if $('.feeds-controller.index-action').length
  vue = new Vue
    data:
      tags: []
      currentTags: []

    compiled: ->
      ($.getJSON Routes.rootPath(tag: @currentTags)).then (data) =>
        @tags = data.tags

  vue.$mount '#main-content'
