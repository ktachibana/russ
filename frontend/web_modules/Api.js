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

  loadInitial() {
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

  subscribeFeed(subscriptionId, subscription) {
    const url = subscriptionId ?
      ApiRoutes.subscriptionPath(subscriptionId) :
      ApiRoutes.subscriptionsPath();
    const method = subscriptionId ? 'put' : 'post';

    return $.ajax(url, {
      type: method,
      dataType: 'json',
      data: {subscription}
    });
  }

  unsubscribeFeed(subscriptionId) {
    return $.ajax(ApiRoutes.subscriptionPath(subscriptionId), {
      type: 'delete',
      dataType: 'json'
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

  importOPML(file) {
    return new Promise((resolve, reject) => {
      let data = new FormData();
      data.append('file', file);
      $.ajax(ApiRoutes.importSubscriptionsPath(), {
        type: 'post',
        dataType: 'json',
        data: data,
        processData: false,
        contentType: false
      }).then(
        resolve,
        (xhr, type, errorThrown) => {
          const errorMessage = (xhr.responseJSON && xhr.responseJSON.error) ?
            xhr.responseJSON.error :
            `${type}: ${errorThrown}`;
          reject(errorMessage);
        }
      );
    });
  }
}

export default new Api();
