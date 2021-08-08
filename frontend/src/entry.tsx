require('bootstrap/dist/js/bootstrap');

import React from 'react';
import ReactDOM from 'react-dom';
import {HashRouter, Route, Redirect, Switch, RouteComponentProps} from 'react-router-dom';
import Application from './Application';
import ItemsPage from './ItemsPage';
import FeedsPage from './FeedsPage';
import SubscriptionPage from './SubscriptionPage';
import ImportPage from './ImportPage';

const paramParser = {
  names: function (param: string): string[] {
    return param ? param.split(',') : []
  },

  integer: function (param: string): number {
    return parseInt(param) || 1
  }
};

const ItemsPageRoute = ({match}: RouteComponentProps<{tags: string, page: string}>) => {
  const pageProps = {
    currentPage: paramParser.integer(match.params.page),
    currentTagNames: paramParser.names(match.params.tags)
  };
  return <ItemsPage {...pageProps} />
};

const FeedsPageRoute = ({match}: RouteComponentProps<{tags: string, page: string}>) => {
  const pageProps = {
    currentTagNames: paramParser.names(match.params.tags),
    page: paramParser.integer(match.params.page)
  };
  return <FeedsPage {...pageProps}/>;
};

const SubscriptionPageRoute = ({match}) => {
  const pageProps = (match.params.encodedUrl) ? {
    encodedUrl: match.params.encodedUrl
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
        <Route path="/subscriptions/new/:encodedUrl" component={SubscriptionPageRoute}/>
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
