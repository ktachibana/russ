import React from 'react';
import { Link } from 'react-router-dom';

export default class HeaderNav extends React.Component {
  subscriptionBookmarklet(l) {
    const apiURLBase = `${l.protocol}//${l.host}/#/subscriptions/new/`;
    const js = `location.href="${apiURLBase}"+encodeURIComponent(location.href);`;

    return `javascript:${js}`;
  }

  logOutClicked(e) {
    e.preventDefault();
    this.props.onLogoutClick();
  }

  render() {
    return (
      <nav className="navbar navbar-default" role="navigation">
        <div className="navbar-header">
          <button className="navbar-toggle" data-target=".navbar-ex1-collapse" data-toggle="collapse" type="button">
            <span className="sr-only">Toggle navigation</span>
            <span className="icon-bar"/>
            <span className="icon-bar"/>
            <span className="icon-bar"/>
          </button>
          <Link to="/items/1/" className="navbar-brand">
            RuSS
          </Link>
        </div>
        <div className="collapse navbar-collapse navbar-ex1-collapse">
          <ul className="nav navbar-nav">
            <li>
              <Link to="/feeds/1/">
                Feeds
              </Link>
            </li>
          </ul>
          <ul className="nav navbar-nav navbar-right">
            <li className="dropdown">
              <a className="dropdown-toggle" data-toggle="dropdown" href="#">
                {this.props.userId}
                <b className="caret"/>
              </a>
              <ul className="dropdown-menu">
                <li><a href={this.subscriptionBookmarklet(window.location)}>RuSS (Bookmarklet)</a></li>
                <li><Link to="/subscriptions/import/">Import OPML</Link></li>
                <li><a rel="nofollow" href="#" onClick={this.logOutClicked.bind(this)}>Sign out</a></li>
              </ul>
            </li>
          </ul>
        </div>
      </nav>
    );
  }
}
