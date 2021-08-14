import $ from 'jquery';
import {EventEmitter2} from 'eventemitter2';
import {Feed, FeedsResponse, InitialState, ItemsResponse, Subscription, SubscriptionResponse, Tag} from "./types";
import {stringify as qsStringify} from 'query-string';

interface Parameter<T = any> {
  [key: string]: T;
}

function buildURL(path: string, parameter?: Parameter) {
  if (parameter) {
    return `${path}?${(qsStringify(parameter, {arrayFormat: 'bracket'}))}`;
  } else {
    return path
  }
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
      throw await response.json();
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
    return this.request(buildURL(path, parameter), 'GET');
  }

  private async post(path: string, parameter?: Parameter) {
    return this.request(path, 'POST', JSON.stringify(parameter))
  }

  private async patch(path: string, parameter?: Parameter) {
    return this.request(path, 'PATCH', JSON.stringify(parameter))
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

  async loadItems(parameter: Parameter): Promise<ItemsResponse> {
    return this.get('/items', parameter);
  }

  async loadFeeds(parameter: Parameter): Promise<FeedsResponse> {
    return this.get('/feeds', parameter);
  }

  async loadTags(): Promise<Tag[]> {
    return this.get('/tags')
  }

  async subscribeFeed(subscription: Parameter): Promise<SubscriptionResponse> {
    return this.post('/subscriptions', {subscription});
  }

  async updateSubscription(subscriptionId: number, subscription: Parameter): Promise<SubscriptionResponse> {
    return this.patch(`/subscriptions/${subscriptionId}`, {subscription})
  }

  async unsubscribeFeed(subscriptionId: number) {
    return this.delete(`/subscriptions/${subscriptionId}`);
  }

  async fetchFeed(feedUrl: string): Promise<Feed> {
    return this.get('/subscriptions/new', {url: feedUrl});
  }

  async loadSubscription(id: number, parameter: Parameter): Promise<Subscription> {
    return this.get(`/subscriptions/${id}`, parameter);
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
