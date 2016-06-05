require('expose?jQuery!jquery'); // bootstrapが要求する
require('jquery-ujs');
import React from 'react';
import ReactDOM from 'react-dom';
import {Router, Route, IndexRedirect, hashHistory} from 'react-router';
import App from 'app';
import ItemsPage from 'items-page';
import FeedsPage from 'feeds-page';
import SubscriptionPage from 'subscription-page';
import ImportPage from 'import-page';

ReactDOM.render(
  <Router history={hashHistory}>
    <Route path="/" component={App}>
      <IndexRedirect to="items/"/>
      <Route path="items/(:tags)" component={ItemsPage}/>
      <Route path="feeds/(:tags)" component={FeedsPage}/>
      <Route path="subscriptions/import/" component={ImportPage}/>
      <Route path="subscriptions/new/:url" component={SubscriptionPage}/>
      <Route path="subscriptions/:id" component={SubscriptionPage}/>
    </Route>
  </Router>,
  document.getElementById('main-content')
);
