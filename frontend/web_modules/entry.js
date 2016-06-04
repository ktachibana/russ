require('expose?jQuery!jquery'); // bootstrapが要求する
require('jquery-ujs');
import React from 'react';
import ReactDOM from 'react-dom';
import {Router, Route, IndexRedirect, hashHistory} from 'react-router';
import App from 'app';
import ItemsPage from 'items-page';

ReactDOM.render(
  <Router history={hashHistory}>
    <Route path="/" component={App}>
      <IndexRedirect to="items/"/>
      <Route path="items/(:tags)" component={ItemsPage}/>
    </Route>
  </Router>,
  document.getElementById('main-content')
);
