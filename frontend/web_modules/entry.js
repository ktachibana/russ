require('expose?jQuery!jquery'); // bootstraが要求する
import App from 'app';
import React from 'react';
import ReactDOM from 'react-dom';

ReactDOM.render(<App/>, document.getElementById('main-content'));
