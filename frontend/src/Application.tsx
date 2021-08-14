import React, {useState, useEffect} from 'react';
import _ from 'underscore';
import LoginFilter from './LoginFilter';
import NowLoadingFilter from './NowLoadingFilter';
import FlashMessages from './FlashMessages';
import Layout from './Layout';
import api from './Api';
import {InitialState, Message, User} from "./types";
import {Listener} from "eventemitter2";

interface Props {
  children: React.ReactNode
}

export default function Application({children}: Props): JSX.Element {
  const [initialized, setInitialized] = useState<boolean>(false);
  const [flashMessages, setFlashMessages] = useState<Message[]>([]);
  const [user, setUser] = useState<User>();

  useEffect(() => {
    const listener = api.on(
      'flashMessages',
      (rawMessages: [string, string][]) => {
        const messages = rawMessages.map(message => createFlashMessage(message[0], message[1]));
        addFlashMessages(messages);
      },
      {objectify: true}
    ) as Listener;

    return () => {
      listener.off();
    };
  }, []);

  useEffect(() => {
    fetchInitialState();
  }, []);

  function createFlashMessage(type: string, text: string): Message {
    return {
      id: _.uniqueId(),
      type: type,
      text: text
    };
  }

  function addFlashMessages(newFlashMessages: Message[]) {
    setFlashMessages([...flashMessages, ...newFlashMessages]);

    const addedIds = newFlashMessages.map(message => message.id);

    // TODO
    window.setTimeout(() => {
      const restMessages = flashMessages.filter(message => !addedIds.includes(message.id));
      setFlashMessages(restMessages);
    }, 3000);
  }

  async function fetchInitialState() {
    try {
      const {user} = await api.loadInitial();
      setInitialized(true);
      setUser(user);
    } catch (e) {
      // TODO: show error message.
      setInitialized(true);
      setUser(undefined);
    }
  }

  function loggedIn(initialState: InitialState) {
    setUser(initialState.user);
  }

  function loginFailed(message: string) {
    addFlashMessages([createFlashMessage('alert', message)]);
  }

  async function logout() {
    // TODO: cookieではなくtokenを使ってクライアント側でログイン状態を消せるように
    const clearUser = () => {
      setUser(undefined);
    };

    api.logout().then(clearUser, clearUser);
  }

  function flashMessageClosed(id: string) {
    const newFlashMessages = flashMessages.filter(message => message.id !== id);
    setFlashMessages(newFlashMessages);
  }

  let content = null;
  if (!initialized) {
    content = <NowLoadingFilter/>;
  } else if (!user) {
    content = <LoginFilter
      onLogin={(initialState) => { loggedIn(initialState) }}
      onLoginFailure={(message) => { loginFailed(message)}}/>;
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
