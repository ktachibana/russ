import $ from 'jquery';
import ApiRoutes from 'app/ApiRoutes';
import {EventEmitter2} from 'eventemitter2';

class Api extends EventEmitter2 {
  constructor() {
    super();

    $.ajaxPrefilter((options, originalOptions, xhr) => {
      if (!options.crossDomain && this.token) {
        xhr.setRequestHeader('X-CSRF-Token', this.token);
      }
    });

    $.ajaxSetup({
      complete: (xhr) => {
        var token = xhr.getResponseHeader('X-CSRF-Token');
        if (token) {
          this.token = token;
        }

        var flash = xhr.getResponseHeader('X-Flash-Messages');
        if (flash) {
          var flashMessages = JSON.parse(decodeURIComponent(flash));
          if (flashMessages && flashMessages.length) {
            this.emit('flashMessages', flashMessages);
          }
        }
      }
    });
  }

  initial() {
    return $.getJSON(ApiRoutes.initialPath());
  }

  login(user) {
    return new Promise((resolve, reject) => {
      $.ajax(ApiRoutes.userSessionPath(), {
        method: 'post',
        dataType: 'json',
        data: {user}
      }).then(
        (data) => {
          resolve(data);
        },
        (xhr, type, errorThrown) => {
          if (xhr.responseJSON && xhr.responseJSON.error) {
            reject(xhr.responseJSON.error);
          } else {
            reject(`${type}: ${errorThrown}`);
          }
        });
    });
  }

  logout() {
    return $.ajax(ApiRoutes.destroyUserSessionPath(), {
      method: 'delete'
    });
  }

  loadItems({tag, page, subscriptionId}) {
    return $.getJSON(ApiRoutes.itemsPath({tag, page, subscription_id: subscriptionId}));
  }

  loadFeeds({tag, page}) {
    return $.getJSON(ApiRoutes.feedsPath({tag, page}));
  }

  saveFeed(id, subscription) {
    const url = id ?
      ApiRoutes.subscriptionPath(id) :
      ApiRoutes.subscriptionsPath();
    const method = id ? 'put' : 'post';

    return $.ajax(url, {
      type: method,
      dataType: 'json',
      data: {subscription}
    });
  }

  loadSubscription(id) {
    return $.getJSON(ApiRoutes.subscriptionPath(id));
  }

  fetchFeed(feedUrl) {
    return $.getJSON(ApiRoutes.newSubscriptionPath(), {
      url: feedUrl
    });
  }
}

export default new Api();
