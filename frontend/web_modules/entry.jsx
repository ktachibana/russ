require('expose?jQuery!jquery'); // bootstrapが要求する
require('jquery-ujs');
import React from 'react';
import ReactDOM from 'react-dom';
import {Router, Route, IndexRedirect, hashHistory} from 'react-router';
import $ from 'jquery';
import Application from 'Application';
import ItemsPage from 'ItemsPage';
import FeedsPage from 'FeedsPage';
import SubscriptionPage from 'SubscriptionPage';
import ImportPage from 'ImportPage';

$.ajaxSetup({
  complete: (xhr) => {
    var token = xhr.getResponseHeader('X-CSRF-Token');
    if(token) {
      $('meta[name="csrf-token"]').attr('content', token);
    }
  }
});

ReactDOM.render(
  <Router history={hashHistory}>
    <Route path="/" component={Application}>
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
