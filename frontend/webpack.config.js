var path = require('path');

module.exports = {
  entry: 'entry',
  output: {
    path: path.resolve(__dirname, '../public/assets'),
    filename: 'application.js'
  },
  module: {
    loaders: [
      { test: /\.coffee$/, loaders: ['coffee'] },
      { test: /\.jsx?$/, loader: 'babel', query: { compact: false } }
    ]
  },
  resolve: {
    extensions: ['', '.webpack.js', '.web.js', '.coffee', '.jsx', '.js']
  }
};
