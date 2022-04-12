// webpack.config.js
const path = require( 'path' );

module.exports = {
    context: __dirname,
    entry: {
		'timesheet':'./includes/js/timesheet.js'
	},
    output: {
        path: path.resolve( __dirname, 'resources/js' ),
        filename: '[name].js',
    },
    resolve: {
        alias: {
            'vue$': 'vue/dist/vue.esm.js'
        },
        extensions: ['*', '.js', '.vue', '.json']
    },
    module: {
		rules: [
			{
			  test: /\.js$/,
			  loader: 'babel-loader'
			}
		  ]
    }
};