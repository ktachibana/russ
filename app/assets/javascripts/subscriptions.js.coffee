Vue.component 'edit-subscription-page',
  template: '#edit-subscription-page',
  inherit: true,
  data: ->
    feed: null
  compiled: ->
    url = decodeURIComponent(@$root.params.feedUrl)
    ($.getJSON(Routes.newSubscriptionPath(), url: url)).then (data) =>
      @$data = data


$ ->
  form = $('#new_subscription')
  form.on 'ajax:success', (data, status, xhr) ->
    location.href = Routes.rootPath
  form.on 'ajax:error', (xhr, status, error) ->
    if status.responseJSON?.type == 'validation'
      alert(JSON.stringify(status.responseJSON.errors))
    else
      alert('unknown error')
      console.error(xhr, status, error)
