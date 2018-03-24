import React from 'react';
import { Link } from 'react-router-dom';
import HeaderNav from 'HeaderNav';

export default class Layout extends React.Component {
  render() {
    return (
      <div>
        <HeaderNav userId={this.props.user.email} onLogoutClick={this.props.onLogoutClick}/>
        <div>{this.props.children}</div>
      </div>
    );
  }
}
