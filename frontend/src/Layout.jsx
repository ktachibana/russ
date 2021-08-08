import React from 'react';
import { Link } from 'react-router-dom';
import HeaderNav from './HeaderNav';

export default function Layout({user, onLogoutClick, children}) {
  return (
    <div>
      <HeaderNav userId={user.email} onLogoutClick={onLogoutClick}/>
      <div>{children}</div>
    </div>
  );
}
