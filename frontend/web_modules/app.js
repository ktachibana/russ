import React from 'react';
import $ from 'jquery';
import Routes from './app/routes';

class App extends React.Component {
  constructor(props) {
    super(props);
    this.currentPage = null;
    this.currentTags = [];
    this.tags = [];
    this.params = {};
  }

  componentDidMount() {
    return this.updateTags();
  }

  get currentTagParams() {
    return this.currentTags.map(tag => encodeURIComponent(tag)).join(',');
  }

  get rootPath() {
    return `#/items/${this.currentTagParams}`;
  }

  get feedsPath() {
    return `#/feeds/${this.currentTagParams}`;
  }

  updateTags() {
    return $.getJSON(Routes.tagsPath()).then((tags) => {
      this.tags = tags;
    });
  }

  setCurrentTags(tags) {
    return this.currentTags = tags.sort();
  }

  render() {
    return (
      <div className="container">
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
                  {/* TODO: implement email */}
                  <b className="caret"/>
                </a>
                <ul className="dropdown-menu">
                  {/* TODO: implement bookmarklet */}
                  <li><a href="javascript:location.href=escape(location.href);">RuSS (Bookmarklet)</a></li>
                  <li><a href="/subscriptions/upload">Import OPML</a></li>
                  <li><a rel="nofollow" data-method="delete" href="/users/sign_out">Sign out</a></li>
                </ul>
              </li>
            </ul>
          </div>
        </nav>
      </div>
    );
  }
}

export default App;
