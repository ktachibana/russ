import $ from 'jquery';
import {EventEmitter2} from 'eventemitter2';

interface Parameter<T = any> {
  [key: string]: T;
}

class Api extends EventEmitter2 {
  private token?: string;

  constructor() {
    super();

    $.ajaxPrefilter((options, originalOptions, xhr) => {
      if (!options.crossDomain && this.token) {
        xhr.setRequestHeader('X-CSRF-Token', this.token);
      }
    });

    $.ajaxSetup({
      complete: (xhr) => {
        const token = xhr.getResponseHeader('X-CSRF-Token');
        if (token) {
          this.token = token;
        }

        const flash = xhr.getResponseHeader('X-Flash-Messages');
        if (flash) {
          const flashMessages = JSON.parse(decodeURIComponent(flash));
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

  login(user: Parameter) {
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

  loadItems(parameter: Parameter) {
    return $.getJSON('/items', parameter);
  }

  loadFeeds(parameter: Parameter) {
    return $.getJSON('/feeds', parameter);
  }

  loadTags() {
    return $.getJSON('/tags')
  }

  subscribeFeed(subscriptionId: number | undefined, subscription: Parameter) {
    const url = subscriptionId ? `/subscriptions/${subscriptionId}` : '/subscriptions';
    const method = subscriptionId ? 'patch' : 'post';

    return $.ajax(url, {
      type: method,
      dataType: 'json',
      data: {subscription}
    });
  }

  unsubscribeFeed(subscriptionId: number) {
    return $.ajax(`/subscriptions/${subscriptionId}`, {
      type: 'delete',
      dataType: 'json'
    });
  }

  loadSubscription(id: number, parameter: Parameter) {
    return $.getJSON(`/subscriptions/${id}`, parameter);
  }

  fetchFeed(feedUrl: string) {
    return $.getJSON('/subscriptions/new', {url: feedUrl});
  }

  importOPML(file: File) {
    return new Promise((resolve, reject) => {
      const data = new FormData();
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
