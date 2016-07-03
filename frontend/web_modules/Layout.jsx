import React from 'react';
import { Link } from 'react-router';
import $ from 'jquery';
import ApiRoutes from 'app/ApiRoutes';
import HeaderNav from 'HeaderNav';

export default class Layout extends React.Component {
  logOutClicked() {
    $.ajax(ApiRoutes.destroyUserSessionPath(), {
      method: 'delete'
    }).then(() => {
      this.props.onLogout();
    }, () => {
      this.props.onLogout();
    });
  }

  render() {
    return (
      <div>
        <HeaderNav userId={this.props.user.email} onLogoutClick={this.logOutClicked.bind(this)}/>
        <div>
          {(this.props.children && React.cloneElement(this.props.children, {
            tags: this.props.tags
          }))}
        </div>
      </div>
    );
  }
}
