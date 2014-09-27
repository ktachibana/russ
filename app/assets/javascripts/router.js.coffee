class @Router
  @routes = []

  @on: (path, callback) ->
    regexp = @_compilePath(path)
    @routes.push path: path, pathRegexp: regexp, callback: callback

  @_compilePath: (path) ->
    # XXX: -とか.とかをunescapeしていないので、pathにそれらを与えるのはよくない
    # https://github.com/pillarjs/path-to-regexp を使うべきかも
    source = path.replace(/:\w+/g, '([^/]+)')
    new RegExp("^#{source}$")

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
