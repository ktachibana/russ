Vue.component 'edit-subscription-page',
  template: '#edit-subscription-page',
  inherit: true,

  compiled: ->
    url = decodeURIComponent(@$root.params.feedUrl)
    ($.getJSON(Routes.newSubscriptionPath(), url: url)).then (data) =>
      @$data = data

  methods:
    onFormSuccess: (data, status, xhr) ->
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
