import $ from 'jquery';
import {EventEmitter2} from 'eventemitter2';
import {InitialState, Tag, User} from "./types";

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

  private async request(path: string, method: string, body?: string) {
    const response = await fetch(
      path,
      {
        method: method,
        headers: new Headers({
          'X-CSRF-Token': this.token!,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }),
        body: body
      }
    );

    this.handleCompletedResponse(response);

    if (response.ok) {
      return await response.json();
    } else {
      throw (await response.json()).error;
    }
  }

  private handleCompletedResponse(response: Response) {
    const token = response.headers.get('X-CSRF-Token');
    if (token) {
      this.token = token;
    }

    const encodedJSONMessages = response.headers.get('X-Flash-Messages');
    if (encodedJSONMessages) {
      const flashMessages = JSON.parse(decodeURIComponent(encodedJSONMessages));
      if (flashMessages && flashMessages.length) {
        this.emit('flashMessages', flashMessages);
      }
    }
  }

  private async get(path: string, parameter?: Parameter) {
    return this.request(path, 'GET');
  }

  private async post(path: string, parameter?: Parameter) {
    return this.request(path, 'POST', JSON.stringify(parameter))
  }

  private async delete(path: string) {
    return this.request(path, 'DELETE');
  }

  async loadInitial(): Promise<InitialState> {
    return await this.get('/initial');
  }

  async signIn(user: Parameter): Promise<InitialState> {
    return await this.post('/users/sign_in', {user});
  }

  async logout(): Promise<any> {
    return await this.delete('/users/sign_out');
  }

  loadItems(parameter: Parameter) {
    return $.getJSON('/items', parameter);
  }

  loadFeeds(parameter: Parameter) {
    return $.getJSON('/feeds', parameter);
  }

  async loadTags(): Promise<Tag[]> {
    return await this.get('/tags')
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
