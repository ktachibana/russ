import React, {useState, useEffect} from 'react';
import _ from 'underscore';
import LoginFilter from './LoginFilter.tsx';
import NowLoadingFilter from './NowLoadingFilter';
import FlashMessages from './FlashMessages';
import Layout from './Layout';
import api from './Api';

export default function Application({children}) {
  const [initialized, setInitialized] = useState(false);
  const [flashMessages, setFlashMessages] = useState([]);
  const [user, setUser] = useState(null);

  useEffect(() => {
    api.on('flashMessages', (rawMessages) => {
      const messages = rawMessages.map(message => createFlashMessage(message[0], message[1]));
      addFlashMessages(messages);
    });
  }, []);

  useEffect(() => {
    fetchInitialState();
  }, []);

  function createFlashMessage(type, text) {
    return {
      id: _.uniqueId(),
      type: type,
      text: text
    };
  }

  function addFlashMessages(newFlashMessages) {
    setFlashMessages([...flashMessages, ...newFlashMessages]);

    const addedIds = newFlashMessages.map(message => message.id);

    // TODO
    window.setTimeout(() => {
      const restMessages = flashMessages.filter(message => !addedIds.includes(message.id));
      setFlashMessages(restMessages);
    }, 3000);
  }

  function fetchInitialState() {
    return api.loadInitial().then((data) => {
      setInitialized(true);
      setUser(data.user);
    }, (xhr, type, statusText) => {
      // TODO: show error message.
      setInitialized(true);
      setUser(null);
    });
  }

  function loggedIn(initialState) {
    setUser(initialState.user);
  }

  function loginFailed(message) {
    addFlashMessages([createFlashMessage('alert', message)]);
  }

  function logout() {
    const clearUser = () => {
      setUser(null);
    };

    api.logout().then(clearUser, clearUser);
  }

  function flashMessageClosed(id) {
    const newFlashMessages = flashMessages.filter(message => message.id !== id);
    setFlashMessages(newFlashMessages);
  }

  let content = null;
  if (!initialized) {
    content = <NowLoadingFilter/>;
  } else if (!user) {
    content = <LoginFilter onLogin={(initialState) => { loggedIn(initialState) }} onLoginFailure={(message) => { loginFailed(message)}}/>;
  } else {
    content =
      <Layout user={user} onLogoutClick={() => { logout() }}>
        {children}
      </Layout>;
  }

  return (
    <div>
      {content}
      <FlashMessages messages={flashMessages} onClose={(id) => { flashMessageClosed(id) }}/>
    </div>
  );
}
