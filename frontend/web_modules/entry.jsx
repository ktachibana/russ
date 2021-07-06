require('bootstrap/dist/js/bootstrap');

import $ from 'expose-loader?exposes=$,jQuery!jquery'; // bootstrapが要求する
import React from 'react';
import ReactDOM from 'react-dom';
import {HashRouter, Route, Redirect, Switch} from 'react-router-dom';
import Application from 'Application';
import ItemsPage from 'ItemsPage';
import FeedsPage from 'FeedsPage';
import SubscriptionPage from 'SubscriptionPage';
import ImportPage from 'ImportPage';

const paramParser = {
  names: function (param) {
    return param ? param.split(',') : []
  },
  integer: function (param) {
    return parseInt(param) || 1
  }
};

const ItemsPageRoute = ({match}) => {
  const pageProps = {
    currentTagNames: paramParser.names(match.params.tags),
    currentPage: paramParser.integer(match.params.page)
  };
  return <ItemsPage {...pageProps} />
};

const FeedsPageRoute = ({match}) => {
  const pageProps = {
    currentTagNames: paramParser.names(match.params.tags),
    page: paramParser.integer(match.params.page)
  };
  return <FeedsPage {...pageProps}/>;
};

const SubscriptionPageRoute = ({match}) => {
  const pageProps = (match.params.url) ? {
    url: match.params.url
  } : {
    id: match.params.id,
    page: paramParser.integer(match.params.page)
  };
  return <SubscriptionPage {...pageProps}/>;
};

const ApplicationRoute = () => {
  return (
    <Application>
      <Switch>
        <Route path="/items/:page/:tags*" component={ItemsPageRoute}/>
        <Route path="/feeds/:page/:tags*" component={FeedsPageRoute}/>
        <Route path="/subscriptions/import/" component={ImportPage}/>
        <Route path="/subscriptions/new/:url" component={SubscriptionPageRoute}/>
        <Route path="/subscriptions/:page/:id" component={SubscriptionPageRoute}/>
      </Switch>
    </Application>
  );
};

ReactDOM.render(
  <HashRouter>
    <Switch>
      <Route exact path="/" render={() => <Redirect to="/items/1/"/>}/>
      <Route path="/" component={ApplicationRoute}/>
    </Switch>
  </HashRouter>,
  document.getElementById('main-content')
);
