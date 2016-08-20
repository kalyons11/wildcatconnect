// Modules configuration.

exports.handler = function(event, context, callback) {

    var https = require('https');
    var http = require('http');
    var config = require('./config');

    var postData = JSON.stringify(config.data);

    var options = {
        host: config.host,
        port: config.port,
        path: config.path,
        method: 'POST',
        headers: {
            accept: '*/*',
            'Content-Type': 'application/json',
            'Content-Length': postData.length
        }
    };

    if (config.secure) {
        https.request(options, function(res){
            res.on('data', function(data){
                var result = data.toString('utf-8');
                console.log(result);
            });
        }).write(postData);
    } else {
        http.request(options, function(res){
            res.on('data', function(data){
                var result = data.toString('utf-8');
                console.log(result);
            });
        }).write(postData);
    }
};

//exports.handler();