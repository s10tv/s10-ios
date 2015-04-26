var assert = require('assert');
['AZURE_ACCOUNTID', 'AZURE_ACCESSKEY', 'HEROKU_AUTH_TOKEN','CIRCLE_BUILD_NUMBER', 'CIRCLE_ARTIFACTS', 'BN'].map(function(key) {
    assert(process.env[key], 'Required env variable ' + key + ' is missing');
});

var fs = require('fs'),
    request = require('request'),
    azure = require('pkgcloud').storage.createClient({
  provider: 'azure',
  storageAccount: process.env.AZURE_ACCOUNTID,
  storageAccessKey: process.env.AZURE_ACCESSKEY
});
var ipaPath = process.env.CIRCLE_ARTIFACTS + '/' + process.env.BN + '.ipa';

var progressStream = require('progress-stream');
var readStream = fs.createReadStream(ipaPath);
var writeStream = azure.upload({
    container: 'ketch-dev', // TODO: Change this to 'builds' after modifying permission on builds container
    remote: 'latest-beta.ipa'
});
var progress = progressStream();

progress.on('progress', function(progress) {
    console.log('Transferred: ' + (progress.transferred/1024/1024).toFixed(2) + ' mb');
});
writeStream.on('error', function(err) {
    console.log('Failed to update latest beta build', err);
    process.exit(1);
});
writeStream.on('success', function(file) {
    console.log('Will update softMinBuild on heroku server');
    request.patch('https://api.heroku.com/apps/ketch-beta/config-vars', {
        headers: {
            'Authorization': 'Bearer ' + process.env.HEROKU_AUTH_TOKEN,
            'Accept': 'application/vnd.heroku+json; version=3',
            'User-Agent': 'Circle Script'
        },
        json: {
            SOFT_MIN_BUILD: process.env.CIRCLE_BUILD_NUMBER
        }
    }, function(err, res, body) {
        if (!res || res.statusCode != 200) {
            console.log('Failed to update SOFT_MIN_BUILD on ketch-beta\n', body);
            process.exit(1);
        }
        console.log('Successfully updated SOFT_MIN_BUILD on ketch-beta');
    });
});

readStream.pipe(progress).pipe(writeStream);
