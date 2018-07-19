const path = require('path')
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const BrotliPlugin = require('brotli-webpack-plugin')
const ImageminPlugin = require('imagemin-webpack-plugin').default
const glob = require('glob')
const mozJPEG = require('imagemin-mozjpeg')

module.exports = {
  context: path.resolve(__dirname, './web/static/'),
  entry: {
    'js/bundle': './js/app.js',
    'css/style': './styles/style.less',
    'css/vendor': [
      '@fortawesome/fontawesome-free/less/fontawesome.less',
      '@fortawesome/fontawesome-free/less/fa-brands.less',
      '@fortawesome/fontawesome-free/less/fa-solid.less',
      'highlight.js/styles/obsidian.css'
    ]
  },
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, './priv/static'),
    publicPath: '/'
  },
  module: {
    rules: [
      {
        test: /\.(less|css)$/,
        use: [
          process.env.NODE_ENV === 'development'
            ? 'style-loader'
            : MiniCssExtractPlugin.loader,
          'css-loader',
          'less-loader'
        ]
      },
      {
        test: /\.(woff|woff2|eot|ttf|svg)(\?.*$|$)/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: 'fonts/[name].[ext]'
            }
          }
        ]
      }
    ]
  },
  plugins: [
    new ImageminPlugin({
      externalImages: {
        context: '.',
        sources: glob.sync('web/static/assets/*.jpg'),
        destination: 'priv/static'
      },
      plugins: [
        mozJPEG({
          quality: 75,
          progressive: true
        })
      ]
    }),
    new MiniCssExtractPlugin({ fileName: '[name]-[hash].css' }),
    new BrotliPlugin()
  ],
  optimization: {
    minimizer: [
      new UglifyJsPlugin({
        cache: true,
        parallel: true,
        sourceMap: process.env.NODE_ENV === 'development' // set to true if you want JS source maps
      }),
      new OptimizeCSSAssetsPlugin({})
    ]
  }
}
