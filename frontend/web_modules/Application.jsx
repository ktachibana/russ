import React from 'react';
import $ from 'jquery';
import ApiRoutes from './app/ApiRoutes';
import LoginFilter from 'LoginFilter';
import NowLoadingFilter from 'NowLoadingFilter';

export default class Application extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      initialized: false,
      user: null,
      tags: [],
      currentTags: []
    };
    this.params = {};
  }

  componentDidMount() {
    this.fetchInitialState();
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

  fetchInitialState() {
    return $.getJSON(ApiRoutes.initialPath()).then((data) => {
      this.setState({initialized: true, user: data.user, tags: data.tags});
    }, (xhr, type, statusText) => {
      // TODO: show error message.
      this.setState({initialized: true, user: null});
    });
  }

  setCurrentTags(tags) {
    return this.currentTags = tags.sort();
  }

  static get subscriptionBookmarklet() {
    const l = window.location;
    const apiURLBase = `${l.protocol}//${l.host}${ApiRoutes.newSubscriptionPath({url: ''})}`;
    const js = `location.href="${apiURLBase}"+encodeURIComponent(location.href);`;

    return `javascript:${js}`;
  }

  loggedIn(user) {
    this.setState({user: user});
  }

  render() {
    if(!this.state.initialized) {
      return <NowLoadingFilter/>
    }

    if(!this.state.user) {
      return <LoginFilter onLogin={this.loggedIn.bind(this)}/>;
    }

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
                  {this.state.user.email}
                  <b className="caret"/>
                </a>
                <ul className="dropdown-menu">
                  <li><a href={Application.subscriptionBookmarklet}>RuSS (Bookmarklet)</a></li>
                  <li><a href="#/subscriptions/import/">Import OPML</a></li>
                  <li><a rel="nofollow" data-method="delete" href="/users/sign_out">Sign out</a></li>
                </ul>
              </li>
            </ul>
          </div>
        </nav>
        <div>
          {(this.props.children && React.cloneElement(this.props.children, {
            tags: this.state.tags
          }))}
        </div>
      </div>
    );
  }
}
