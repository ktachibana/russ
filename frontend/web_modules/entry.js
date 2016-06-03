require('expose?jQuery!jquery'); // bootstrapが要求する
require('jquery-ujs');
import React from 'react';
import ReactDOM from 'react-dom';
import {Router, Route, IndexRoute, hashHistory} from 'react-router';
import App from 'app';
import RootPage from 'root-page';

ReactDOM.render(
  <Router history={hashHistory}>
    <Route path="/" component={App}>
      <IndexRoute component={RootPage}/>
    </Route>
  </Router>,
  document.getElementById('main-content')
);
