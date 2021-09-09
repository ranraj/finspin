var path = require("path");
var SWPrecacheWebpackPlugin = require('sw-precache-webpack-plugin');
var WebpackPwaManifest = require('webpack-pwa-manifest');

module.exports = {
    entry: {
        app: [
            './src/index.js'
        ]
    },

    output: {
        path: path.resolve(__dirname + '/public'),
        filename: '[name].js',
    },

    module: {
        rules: [{
                test: /\.html$/,
                exclude: /node_modules/,
                loader: 'file-loader?name=[name].[ext]',
            },
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                loader: 'elm-webpack-loader?verbose=true',
            },
            {
                test: /\.css$/,
                use: ['style-loader', 'css-loader']
            }
        ],

        noParse: /\.elm$/,
    },

    plugins: [
        new SWPrecacheWebpackPlugin({
            cacheId: 'ranraj/finspin',
            dontCacheBustUrlsMatching: /\.\w{8}\./,
            filename: 'service-worker.js',
            minify: false,
            navigateFallback: 'index.html',
            staticFileGlobsIgnorePatterns: [/\.map$/, /manifest\.json$/]
        }), new WebpackPwaManifest({
            name: 'Finspin - Progressive Web App',
            short_name: 'Fin spin',
            description: 'Finspin is interactive board for notes - Progressive WebApp',
            background_color: '#ffffff',
            theme_color: '#000000',
            start_url: '/',
            icons: [{
                src: path.resolve('src/static/image/icon.png'),
                sizes: [192],
                destination: path.join('static', 'img')
            }]
        })
    ],

    devServer: {
        inline: true,
        stats: { colors: true },
    },

};