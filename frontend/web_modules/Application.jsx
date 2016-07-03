import React from 'react';
import _ from 'underscore';
import LoginFilter from 'LoginFilter';
import NowLoadingFilter from 'NowLoadingFilter';
import FlashMessages from 'FlashMessages';
import Layout from 'Layout';
import api from 'Api';

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
    api.on('flashMessages', (rawMessages) => {
      const messages = rawMessages.map(message => this.createFlashMessage(message[0], message[1]));
      this.addFlashMessages(messages);
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
    return api.initial().then((data) => {
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

  logout() {
    const clearUser = () => {
      this.setState({user: null});
    };

    api.logout().then(clearUser, clearUser);
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
        <Layout user={this.state.user} tags={this.state.tags} onLogoutClick={this.logout.bind(this)}>
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
