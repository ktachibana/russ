import $ from 'jquery';
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
    return $.getJSON('/initial');
  }

  login(user) {
    return new Promise((resolve, reject) => {
      $.ajax('/users/sign_in', {
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
    return $.ajax('/users/sign_out', {method: 'delete'});
  }

  loadItems({tag, page, subscriptionId}) {
    return $.getJSON('/items', {tag, page, subscription_id: subscriptionId});
  }

  loadFeeds({tag, page}) {
    return $.getJSON('/feeds', {tag, page});
  }

  subscribeFeed(subscriptionId, subscription) {
    const url = subscriptionId ? `/subscriptions/${subscriptionId}` : '/subscriptions';
    const method = subscriptionId ? 'put' : 'post';

    return $.ajax(url, {
      type: method,
      dataType: 'json',
      data: {subscription}
    });
  }

  unsubscribeFeed(subscriptionId) {
    return $.ajax(`/subscriptions/${subscriptionId}`, {
      type: 'delete',
      dataType: 'json'
    });
  }

  loadSubscription({id, page}) {
    return $.getJSON(`/subscriptions/${id}`, {page});
  }

  fetchFeed(feedUrl) {
    return $.getJSON('/subscriptions/new', {url: feedUrl});
  }

  importOPML(file) {
    return new Promise((resolve, reject) => {
      let data = new FormData();
      data.append('file', file);
      $.ajax('/subscriptions/import', {
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
