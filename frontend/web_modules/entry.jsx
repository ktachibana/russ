require('expose?jQuery!jquery'); // bootstrapが要求する
require('bootstrap/dist/js/bootstrap');
require('bootstrap-tokenfield/dist/bootstrap-tokenfield');

import React from 'react';
import ReactDOM from 'react-dom';
import {Router, Route, IndexRedirect, hashHistory} from 'react-router';
import Application from 'Application';
import ItemsPage from 'ItemsPage';
import FeedsPage from 'FeedsPage';
import SubscriptionPage from 'SubscriptionPage';
import ImportPage from 'ImportPage';

const paramParser = {
  names: function(param) {
    return param ? param.split(',') : []
  },
  integer: function(param) {
    return parseInt(param) || 1
  }
};

const ItemsPageRoute = (props) => {
  const pageProps = {
    tags: props.tags,
    currentTagNames: paramParser.names(props.params.tags),
    page: paramParser.integer(props.params.page)
  };
  return <ItemsPage {...pageProps} />
};

const FeedsPageRoute = (props) => {
  const pageProps = {
    tags: props.tags,
    currentTagNames: paramParser.names(props.params.tags),
    page: paramParser.integer(props.params.page)
  };
  return <FeedsPage {...pageProps}/>;
};

const SubscriptionPageRoute = (props) => {
  const pageProps = {
    tags: props.tags,
    id: props.params.id,
    page: paramParser.integer(props.params.page)
  };
  return <SubscriptionPage {...pageProps}/>;
};

ReactDOM.render(
  <Router history={hashHistory}>
    <Route path="/" component={Application}>
      <IndexRedirect to="items/1/"/>
      <Route path="items/:page/(:tags)" component={ItemsPageRoute}/>
      <Route path="feeds/:page/(:tags)" component={FeedsPageRoute}/>
      <Route path="subscriptions/import/" component={ImportPage}/>
      <Route path="subscriptions/new/:url" component={SubscriptionPage}/>
      <Route path="subscriptions/:page/:id" component={SubscriptionPageRoute}/>
    </Route>
  </Router>,
  document.getElementById('main-content')
);
