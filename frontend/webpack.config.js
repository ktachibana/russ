var path = require('path');

module.exports = {
  entry: './web_modules/entry',
  output: {
    path: path.resolve(__dirname, '../public/assets'),
    filename: 'application.js'
  },
  module: {
    rules: [
      { loader: 'babel-loader', test: /\.jsx?$/, exclude: /node_modules/ }
    ]
  },
  resolve: {
    modules: ['web_modules', 'node_modules'],
    extensions: ['.webpack.js', '.jsx', '.js']
  }
};
