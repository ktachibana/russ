Vue = require('vue');

Vue.filter 'date', (momentDate) ->
  momentDate && momentDate.format('YYYY/M/D(ddd) HH:mm')
