import React from 'react';
import $ from 'jquery';
import _ from 'underscore';
import {Base64} from 'js-base64';
import ApiRoutes from './app/ApiRoutes';
import LoginFilter from 'LoginFilter';
import NowLoadingFilter from 'NowLoadingFilter';
import FlashMessages from 'FlashMessages';
import Layout from 'Layout';

export default class Application extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      initialized: false,
      flashMessages: [],
      user: null,
      tags: []
    };
  }

  componentDidMount() {
    $.ajaxSetup({
      complete: (xhr) => {
        var token = xhr.getResponseHeader('X-CSRF-Token');
        if (token) {
          $('meta[name="csrf-token"]').attr('content', token);
        }

        var flash = xhr.getResponseHeader('X-Flash-Messages');
        if (flash) {
          var flashMessages = JSON.parse(Base64.decode(flash));
          if (flashMessages && flashMessages.length) {
            const messages = flashMessages.map(message => this.createFlashMessage(message[0], message[1]));
            this.addFlashMessages(messages);
          }
        }
      }
    });

    this.fetchInitialState();
  }

  createFlashMessage(type, text) {
    return {
      id: _.uniqueId(),
      type: type,
      text: text
    };
  }

  addFlashMessages(newFlashMessages) {
    this.setState({flashMessages: [...this.state.flashMessages, ...newFlashMessages]});
    const addedIds = newFlashMessages.map(message => message.id);

    window.setTimeout(() => {
      var restMessages = this.state.flashMessages.filter(message => !addedIds.includes(message.id));
      this.setState({flashMessages: restMessages});
    }, 3000);
  }

  fetchInitialState() {
    return $.getJSON(ApiRoutes.initialPath()).then((data) => {
      this.setState({initialized: true, user: data.user, tags: data.tags});
    }, (xhr, type, statusText) => {
      // TODO: show error message.
      this.setState({initialized: true, user: null});
    });
  }

  loggedIn(initialState) {
    this.setState({user: initialState.user, tags: initialState.tags});
  }

  loginFailed(message) {
    this.addFlashMessages([this.createFlashMessage('alert', message)]);
  }

  loggedOut() {
    this.setState({user: null});
  }

  flashMessageClosed(id) {
    var newFlashMessages = this.state.flashMessages.filter(message => message.id != id);
    this.setState({flashMessages: newFlashMessages});
  }

  render() {
    let content = null;
    if (!this.state.initialized) {
      content = <NowLoadingFilter/>;
    } else if (!this.state.user) {
      content = <LoginFilter onLogin={this.loggedIn.bind(this)} onLoginFailure={this.loginFailed.bind(this)}/>;
    } else {
      content =
        <Layout user={this.state.user} tags={this.state.tags} onLogout={this.loggedOut.bind(this)}>
          {this.props.children}
        </Layout>;
    }

    return (
      <div>
        {content}
        <FlashMessages messages={this.state.flashMessages} onClose={this.flashMessageClosed.bind(this)}/>
      </div>
    );
  }
}
