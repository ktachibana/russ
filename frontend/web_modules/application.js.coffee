# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require bootstrap
#= require bootstrap-tokenfield
#= require vue
#= require underscore
#= require path
#= require js-routes
#= require date-ja-JP

#= require vue-filters
#= require russ
#= require root
#= require feeds
#= require subscriptions
#= require tags
#= require items

require('expose?jQuery!jquery');
require('bootstrap');
require('bootstrap-tokenfield');

require('vue-filters.js.coffee');
require('russ.js.coffee');
require('root.js.coffee');
require('feeds.js.coffee');
require('subscriptions.js.coffee');
require('tags.js.coffee');
require('items.js.coffee');