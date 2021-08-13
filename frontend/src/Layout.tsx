import React from 'react';
import HeaderNav from './HeaderNav';
import {User} from "./types";

interface Props {
  user: User
  onLogoutClick: () => void
  children: React.ReactNode
}

export default function Layout({user, onLogoutClick, children}: Props): JSX.Element {
  return (
    <div>
      <HeaderNav userId={user.email} onLogoutClick={onLogoutClick}/>
      <div>{children}</div>
    </div>
  );
}
