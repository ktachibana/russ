var path = require('path');

module.exports = {
  entry: 'application',
  output: {
    path: path.resolve(__dirname, '../app/assets/javascripts'),
    filename: 'bundle.js'
  },
  module: {
    loaders: [
      { test: /\.coffee$/, loaders: ['coffee'] }
    ]
  },
  resolve: {
    extensions: ['', '.webpack.js', '.web.js', '.coffee', '.js']
  }
};
