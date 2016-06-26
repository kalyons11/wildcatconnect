// Modules configuration.

var express = require('express');
var ParseServer = require('parse-server').ParseServer;
var path = require('path');
var parse = require('parse').Parse;
var config = require('./config');

// Variables configuration.

var appId = config.appId;
var masterKey = config.masterKey;
var serverURL = config.serverURL;
var databaseUri = config.databaseUri;
var logglyToken = config.logglyToken;
var logglySubdomain = config.logglySubdomain;
var nodeTag = config.nodeTag;

// Parse Server configuration.

var api = new ParseServer({
  databaseURI: databaseUri,
  cloud: __dirname + '/cloud/main.js',
  appId: appId,
  masterKey: masterKey,
  serverURL: serverURL
});

// Loggly configuration.

var winston = require('winston');

require('winston-loggly');
 
winston.add(winston.transports.Loggly, {
    token: logglyToken,
    subdomain: logglySubdomain,
    tags: [nodeTag],
    json: true
});

// Client-keys like the javascript key or the .NET key are not necessary with parse-server
// If you wish you require them, you can set them as options in the initialization above:
// javascriptKey, restAPIKey, dotNetKey, clientKey

var app = express();

// Serve static assets from the /public folder

app.use('/public', express.static(path.join(__dirname, '/public')));

// Serve the Parse API on the /parse URL prefix

var mountPath = config.parseMount;
app.use(mountPath, api);

app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

// Parse Server plays nicely with the rest of your web routes

app.get('/', function(req, res) {
  res.status(200).send('Check out Loggly.');
  Parse.initialize('Test-App-Id','WC-Test-Master-Key');
  Parse.serverURL = serverURL;
  var obj = new Parse.Object("GameScore");
  obj.set("testKey", "Here it is!!!");
  obj.set("newKey", "Here we go.");
  obj.save(null, {
    success: function(savedObject) {
      winston.log('info', savedObject);
    },
    error: function(error) {
      winston.log('error', error);
    }
  });
  var query = new Parse.Query("GameScoreTwo");
  query.find({
    success: function(allObjects) {
      winston.log('info', allObjects);
    },
    error: function(newError) {
      winston.log('error', newError);
    }
  });
});

// There will be a test page available on the /test path of your server url
// Remove this before launching your app

app.get('/test', function(req, res) {
  res.sendFile(path.join(__dirname, '/public/test.html'));
});

var port = process.env.PORT || 3000;
var httpServer = require('http').createServer(app);
httpServer.listen(port, function() {
    winston.log('info', 'parse-server-example running on port ' + port + '.');
});

// This will enable the Live Query real-time server

ParseServer.createLiveQueryServer(httpServer);