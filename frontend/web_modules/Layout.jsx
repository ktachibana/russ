import React from 'react';
import { Link } from 'react-router';
import HeaderNav from 'HeaderNav';

export default class Layout extends React.Component {
  render() {
    return (
      <div>
        <HeaderNav userId={this.props.user.email} onLogoutClick={this.props.onLogoutClick}/>
        <div>
          {(this.props.children && React.cloneElement(this.props.children, {
            tags: this.props.tags
          }))}
        </div>
      </div>
    );
  }
}
