Vue.component 'edit-subscription-page',
  template: '#edit-subscription-page',
  inherit: true,

  data: ->
    subscription: null
    tagList: ''

  compiled: ->
    if @params.id
      ($.getJSON(Routes.subscriptionPath(@params.id))).then (subscription) =>
        @subscription = subscription
        @tagList = _.map(subscription.tags, (tag) -> tag.name).join(', ')
    else
      url = decodeURIComponent(@params.feedUrl)
      ($.getJSON(Routes.newSubscriptionPath(), url: url)).then (feed) =>
        @subscription = { feed: feed }

  computed:
    isNewRecord: ->
      !@subscription.id?

    isPersisted: ->
      !@isNewRecord

    subscriptionPath: ->
      Routes.subscriptionPath(id: @subscription.id)

    formUrl: ->
      if @isNewRecord
        Routes.subscriptionsPath()
      else
        @subscriptionPath

    formMethod: ->
      if @isNewRecord
        'post'
      else
        'patch'

    submitText: ->
      if @isNewRecord
        '登録'
      else
        '更新'

  methods:
    onFormSuccess: ->
      location.href = Routes.rootPath

    addTag: (tag) ->
      list = @tagList.split(', ')
      list.push(tag) unless _.contains(list, tag)
      @tagList = list.join(', ')

    onDeleted: ->
      location.href = Routes.rootPath

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