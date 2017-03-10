const path = require('path')
const ExtractTextPlugin = require('extract-text-webpack-plugin')

module.exports = {
    context: path.resolve('./web/static'),
    entry: {
        app: [
            './js/app.js',
            './css/styles.css'
        ],
        vendor: [
          'highlightjs'

        ]
    },
    output: {
        filename: 'js/[name].js',
        path: path.resolve('./priv/static')
    },
    plugins: [
        new ExtractTextPlugin('./css/styles.css')
    ],
    module: {
        rules: [
            {
                test: /\.(css|less)$/,
                use: ExtractTextPlugin.extract({
                    fallback: 'style-loader',
                    use: ['css-loader?minimize=true', 'less-loader']

                })
            },
            {
                test: /\.(png|jpe?g|woff|woff2|eot|ttf|svg)(\?.*$|$)/,
                use: 'file-loader?name=static/assets/[name].[ext]'
            }
        ]
    }
}
