const path = require('path')
const ExtractTextPlugin = require("extract-text-webpack-plugin")

const extractLess = new ExtractTextPlugin({
    filename: "[name].css",
    disable: process.env.NODE_ENV === "development"
})

module.exports = {
    context: path.resolve(__dirname, './web/static/'),
    entry: {
        'css/bundle': './styles/style.less',
        'css/vendor': [
            'purecss/build/base-min.css',
            'purecss/build/grids-responsive-min.css'
        ]
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, './priv/static')
    },
    module: {
        rules: [{
            test: /\.(less|css)$/,
            use: extractLess.extract({
                use: ["css-loader", "less-loader"],
                // use style-loader in development
                fallback: "style-loader"
            })
        }]
    },
    plugins: [
        extractLess
    ]
}
