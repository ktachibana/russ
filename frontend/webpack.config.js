var path = require('path');

module.exports = {
  entry: 'entry',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
  },
  module: {
    loaders: [
      { test: /\.coffee$/, loaders: ['coffee'] },
      { test: /\.js$/, loaders: ['babel'] }
    ]
  },
  resolve: {
    extensions: ['', '.webpack.js', '.web.js', '.coffee', '.js']
  }
};
