Vue.component 'feeds-page',
  template: '#feeds-page'
  inherit: true
  data: ->
    subscriptions: []
    page: 1
    isLastPage: true

  methods:
    readFeeds: ->
      ($.getJSON(Routes.feedsPath(), tag: @$parent.currentTags, page: @page)).then (data) =>
        @isLastPage = data.lastPage
        data.subscriptions

    loadFeeds: ->
      @page = 1
      @readFeeds().then (subscriptions) =>
        @subscriptions = subscriptions

    onTagButtonsChanged: (newTags) ->
      location.hash = "#/feeds/#{newTags.join(',')}"

    onCurrentTagsChanged: ->
      @loadFeeds()

    showMore: ->
      @page += 1
      @readFeeds().then (subscriptions) =>
        @subscriptions = @subscriptions.concat(subscriptions)

  compiled: ->
    @loadFeeds()

  created: ->
    @$on 'tag-buttons-changed', @onTagButtonsChanged
    @$on 'current-tags-changed', @onCurrentTagsChanged

Vue.component 'subscription-row',
  template: '#subscription-row',
  inherit: true
  computed:
    feedPath: ->
      Routes.feedPath(@feed)

    subscriptionPath: ->
      Routes.subscriptionPath(@)

    classList: ->
      ['form', "_#{@id}"]

  methods:
    openDialog: ->
      @$parent.$.editSubscriptionDialog.open(@)

Vue.component 'edit-subscription-dialog',
  template: '#edit-subscription-dialog-template'
  inherit: true

  data: ->
    row: {}
    newTag: ''
    errors: {}

  ready: ->
    form = $('#new_subscription')
    form.on 'ajax:success', @onSuccess
    form.on 'ajax:error', (xhr, status, error) =>
      if status.responseJSON?.type == 'validation'
        @errors = status.responseJSON.errors
      else
        alert('unknown error')
        console.error(xhr, status, error)

  computed:
    $dialog: ->
      $('#edit-subscription-dialog')

  methods:
    open: (row) ->
      @row = row
      @$dialog.modal('show')

    addTag: (tag) ->
      @row.tagList.push(tag) unless _.contains(@row.tagList, tag)

    addNewTag: ->
      return unless @newTag
      @addTag(@newTag)
      @newTag = ''

    removeTag: (tag) ->
      @row.tagList = _.without(@row.tagList, tag)

    onSuccess: (event, data, status) ->
      @$dialog.modal('hide')
