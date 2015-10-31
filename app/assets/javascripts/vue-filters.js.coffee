Vue.filter 'date', (date) ->
  date && date.toString('yyyy/M/d(ddd) HH:mm:ss')
