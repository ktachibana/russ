var path = require('path');

module.exports = {
  entry: './src/entry',
  output: {
    path: path.resolve(__dirname, '../public/assets'),
    filename: 'application.js'
  },
  module: {
    rules: [
      { loader: 'ts-loader', test: /\.tsx?$/, exclude: /node_modules/ },
      { loader: 'babel-loader', test: /\.jsx?$/, exclude: /node_modules/ }
    ]
  },
  resolve: {
    extensions: ['.webpack.js', '.jsx', '.js', '.tsx', '.ts']
  }
};
