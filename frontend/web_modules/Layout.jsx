import React from 'react';
import $ from 'jquery';
import ApiRoutes from './app/ApiRoutes';

export default class Layout extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      currentTags: []
    };
  }

  get currentTagParams() {
    return this.state.currentTags.map(tag => encodeURIComponent(tag)).join(',');
  }

  get rootPath() {
    return `#/items/${this.currentTagParams}`;
  }

  get feedsPath() {
    return `#/feeds/${this.currentTagParams}`;
  }

  static get subscriptionBookmarklet() {
    const l = window.location;
    const apiURLBase = `${l.protocol}//${l.host}/#/subscriptions/new/`;
    const js = `location.href="${apiURLBase}"+encodeURIComponent(location.href);`;

    return `javascript:${js}`;
  }

  logOutClicked(e) {
    e.preventDefault();

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
        <nav className="navbar navbar-default" role="navigation">
          <div className="navbar-header">
            <button className="navbar-toggle" data-target=".navbar-ex1-collapse" data-toggle="collapse" type="button">
              <span className="sr-only">Toggle navigation</span>
              <span className="icon-bar"/>
              <span className="icon-bar"/>
              <span className="icon-bar"/>
            </button>
            <a href={this.rootPath} className="navbar-brand">
              RuSS
            </a>
          </div>
          <div className="collapse navbar-collapse navbar-ex1-collapse">
            <ul className="nav navbar-nav">
              <li>
                <a href={this.feedsPath}>
                  Feeds
                </a>
              </li>
            </ul>
            <ul className="nav navbar-nav navbar-right">
              <li className="dropdown">
                <a className="dropdown-toggle" data-toggle="dropdown" href="#">
                  {this.props.user.email}
                  <b className="caret"/>
                </a>
                <ul className="dropdown-menu">
                  <li><a href={Layout.subscriptionBookmarklet}>RuSS (Bookmarklet)</a></li>
                  <li><a href="#/subscriptions/import/">Import OPML</a></li>
                  <li><a rel="nofollow" href="#" onClick={this.logOutClicked.bind(this)}>Sign out</a></li>
                </ul>
              </li>
            </ul>
          </div>
        </nav>
        <div>
          {(this.props.children && React.cloneElement(this.props.children, {
            tags: this.props.tags
          }))}
        </div>
      </div>
    );
  }
}
