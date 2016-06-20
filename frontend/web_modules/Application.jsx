import React from 'react';
import $ from 'jquery';
import {Base64} from 'js-base64';
import ApiRoutes from './app/ApiRoutes';
import LoginFilter from 'LoginFilter';
import NowLoadingFilter from 'NowLoadingFilter';
import FlashMessage from 'FlashMessage';
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
            this.setState({flashMessages});
          }
        }
      }
    });

    this.fetchInitialState();
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
    this.setState({flashMessages: [...this.state.flashMessages, ['alert', message]]});
  }

  loggedOut() {
    this.setState({user: null});
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
        {this.state.flashMessages.map((message) =>
          <FlashMessage key={message[0]} name={message[0]}>{message[1]}</FlashMessage>
        )}

        {content}
      </div>
    );
  }
}
