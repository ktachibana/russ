import {EventEmitter2} from 'eventemitter2';
import {Feed, SubscriptionsResponse, InitialState, ItemsResponse, ShowSubscriptionResponse, UpdateSubscriptionResponse, Tag} from "./types";
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

  private async request(path: string, method: string, body?: string | FormData) {
    const headers = {
      'X-CSRF-Token': this.token!,
      'Accept': 'application/json'
    } as { [key: string]: string };
    if (!(body instanceof FormData)) {
      headers['Content-Type'] = 'application/json'
    }

    const response = await fetch(
      path,
      {
        method: method,
        headers: headers,
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

  private async postFile(path: string, formData: FormData) {
    return this.request(path, 'POST', formData);
  }

  private async patch(path: string, parameter?: Parameter) {
    return this.request(path, 'PATCH', JSON.stringify(parameter))
  }

  private async delete(path: string) {
    return this.request(path, 'DELETE');
  }

  async loadInitial(): Promise<InitialState> {
    return this.get('/initial');
  }

  async signIn(user: Parameter): Promise<InitialState> {
    return this.post('/users/sign_in', {user});
  }

  async logout(): Promise<any> {
    return this.delete('/users/sign_out');
  }

  async loadItems(parameter: Parameter): Promise<ItemsResponse> {
    return this.get('/items', parameter);
  }

  async loadSubscriptions(parameter: Parameter): Promise<SubscriptionsResponse> {
    return this.get('/feeds', parameter); // TODO: URLはやっぱり/subscriptionsでよさそう
  }

  async loadTags(): Promise<Tag[]> {
    return this.get('/tags')
  }

  async subscribeFeed(subscription: Parameter): Promise<UpdateSubscriptionResponse> {
    return this.post('/subscriptions', {subscription});
  }

  async updateSubscription(subscriptionId: number, subscription: Parameter): Promise<UpdateSubscriptionResponse> {
    return this.patch(`/subscriptions/${subscriptionId}`, {subscription})
  }

  async unsubscribeFeed(subscriptionId: number) {
    return this.delete(`/subscriptions/${subscriptionId}`);
  }

  async fetchFeed(feedUrl: string): Promise<ShowSubscriptionResponse> {
    return this.get('/subscriptions/new', {url: feedUrl});
  }

  async loadSubscription(id: number, parameter: Parameter): Promise<ShowSubscriptionResponse> {
    return this.get(`/subscriptions/${id}`, parameter);
  }

  async importOPML(file: File) {
    const data = new FormData();
    data.append('file', file);
    return this.postFile('/subscriptions/import', data);
  }
}

export default new Api();
