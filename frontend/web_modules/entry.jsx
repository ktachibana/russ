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

const ItemsPageRoute = (props) => {
  const pageProps = {
    tags: props.tags,
    currentTagNames: props.params.tags ? props.params.tags.split(',') : [],
    page: parseInt(props.params.page) || 1
  };
  return <ItemsPage {...pageProps} />
};

ReactDOM.render(
  <Router history={hashHistory}>
    <Route path="/" component={Application}>
      <IndexRedirect to="items/1/"/>
      <Route path="items/:page/(:tags)" component={ItemsPageRoute}/>
      <Route path="feeds/(:tags)" component={FeedsPage}/>
      <Route path="subscriptions/import/" component={ImportPage}/>
      <Route path="subscriptions/new/:url" component={SubscriptionPage}/>
      <Route path="subscriptions/:id" component={SubscriptionPage}/>
    </Route>
  </Router>,
  document.getElementById('main-content')
);
