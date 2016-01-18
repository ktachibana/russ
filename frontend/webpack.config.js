var path = require('path');

module.exports = {
  entry: 'application.js.coffee',
  output: {
    path: path.resolve(__dirname, '../public'),
    filename: 'bundle.js'
  },
  module: {
    loaders: [
      { test: /\.js.coffee$/, loaders: ['coffee'] }
    ]
  }
};
