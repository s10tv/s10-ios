var assert = require('assert');
['HEROKU_AUTH_TOKEN','CIRCLE_BUILD_NUM'].map(function(key) {
    assert(process.env[key], 'Required env variable ' + key + ' is missing');
});

var request = require('request');

request.patch('https://api.heroku.com/apps/s10-dev/config-vars', {
    headers: {
        'Authorization': 'Bearer ' + process.env.HEROKU_AUTH_TOKEN,
        'Accept': 'application/vnd.heroku+json; version=3',
        'User-Agent': 'Circle Script'
    },
    json: {
        SOFT_MIN_BUILD: process.env.CIRCLE_BUILD_NUM
    }
}, function(err, res, body) {
    if (!res || res.statusCode != 200) {
        console.log('Failed to update SOFT_MIN_BUILD on s10-dev\n', body);
        process.exit(1);
    }
    console.log('Successfully updated SOFT_MIN_BUILD on s10-dev');
});
