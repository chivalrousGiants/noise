var debug = process.env.NODE_ENV !== "production";
var webpack = require('webpack');

module.exports = {
  context: __dirname + "/analysis-client",
  entry: [
    __dirname + '/analysis-client/src/index.js'
  ],
  devtool: debug ? "inline-sourcemap" : null,
  output: {
    path: __dirname + '/analysis-client',
    filename: 'bundle.js'
  },
  module: {
    loaders: [{
      test: /\.js?$/,
      loader: 'babel-loader',
      exclude: /node_modules/,
      query: {
        presets: ['es2015']
      }
    }]
  },
  resolve: {
    modulesDirectories: ['node_modules', 'components'],
    extensions: ['', '.js']
  },
  plugins: debug ? [] : [
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.OccurenceOrderPlugin(),
    new webpack.optimize.UglifyJsPlugin({ mangle: false, sourcemap: false }),
  ]
};
