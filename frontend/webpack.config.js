var path = require('path');

module.exports = {
  entry: 'Entry',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
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
