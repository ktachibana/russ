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
        data: {user: user}
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
}

export default new Api();
