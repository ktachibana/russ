class @Router
  @routes = []

  @on: (path, callback) ->
    regexp = @_compilePath(path)
    @routes.push path: path, pathRegexp: regexp, callback: callback

  @_compilePath: (path) ->
    pathToRegexp(path)

  @setCurrentPath: (path) ->
    location.hash = path

  @currentPath: ->
    if location.hash
      location.hash.slice(1)
    else
      ''

  @dispatch: ->
    @setCurrentPath('/') unless @currentPath()

    _.some @routes, (route) =>
      match = route.pathRegexp.exec(@currentPath())
      route.callback.apply(this, match.slice(1)) if match
      match

  @watch: ->
    window.onhashchange = =>
      @setCurrentPath(@currentPath())
      @dispatch()
