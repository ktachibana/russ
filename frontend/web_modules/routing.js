import React from 'react';
import {render} from 'react-dom';
import {Router, Route, IndexRoute, hashHistory} from 'react-router';
import App from 'app';
import RootPage from 'root-page';

module.exports = (
  <Router history={hashHistory}>
    <Route path="/" component={App}>
      <IndexRoute component={RootPage}/>
    </Route>
  </Router>
);
