Vue.component 'edit-subscription-page',
  template: '#edit-subscription-page',
  inherit: true,

  data: ->
    feed: null
    tagList: ''

  compiled: ->
    url = decodeURIComponent(@$root.params.feedUrl)
    ($.getJSON(Routes.newSubscriptionPath(), url: url)).then (data) =>
      @feed = data

  methods:
    onFormSuccess: (data, status, xhr) ->
      location.href = Routes.rootPath

    addTag: (tag) ->
      list = @tagList.split(', ')
      list.push(tag) unless _.contains(list, tag)
      @tagList = list.join(', ')

Vue.directive 'remote', (handler) ->
  form = $(@el)
  form.on 'ajax:success', handler
  form.on 'ajax:error', (xhr, status, error) ->
    if status.responseJSON?.type == 'validation'
      alert(JSON.stringify(status.responseJSON.errors))
    else
      alert('unknown error')
      console.error(xhr, status, error)

Vue.directive 'tokenfield',
  twoWay: true
  bind: ->
    field = $(@el)
    field.tokenfield()
    _.each ['created', 'edited', 'removed'], (eventName) =>
      field.on "tokenfield:#{eventName}token", =>
        list = field.tokenfield('getTokensList', ', ')
        @set(list)

  update: (value) ->
    field = $(@el)
    field.tokenfield('setTokens', value)
