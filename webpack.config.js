const path = require('path')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')

const extractLess = new ExtractTextPlugin({
  filename: '[name].css',
  disable: process.env.NODE_ENV === 'development'
})

module.exports = {
  context: path.resolve(__dirname, './web/static/'),
  entry: {
    'js/bundle': './js/app.js',
    'css/bundle': [
      './styles/style.less',
      './styles/cv.less',
      'highlight.js/styles/obsidian.css'
    ]
  },
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, './priv/static')
  },
  module: {
    rules: [
      {
        test: /\.(less|css)$/,
        use: extractLess.extract({
          use: ['css-loader', 'less-loader'],
          fallback: 'style-loader'
        })
      },
      {
        test: /\.(woff(2)?)(\?v=\d+\.\d+\.\d+)?$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name].[ext]',
              outputPath: 'fonts/'
            }
          }
        ]
      }
    ]
  },
  plugins: [
    new CopyWebpackPlugin([{ from: 'assets/**/*.{jpg,png}' }]),
    extractLess
  ]
}
