module.exports = {
  entry: 'application.js.coffee',
  output: {
    path: __dirname,
    filename: 'bundle.js'
  },
  module: {
    loaders: [
      { test: /\.js.coffee$/, loaders: ['coffee'] }
    ]
  }
};
