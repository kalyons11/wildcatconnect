// Required for LiveQuery configuration.

"use strict";

// Modules configuration.

var express = require('express');
var ParseServer = require('Parse-server').ParseServer;
var path = require('path');
var Parse = require('parse/node').Parse;
var config = require('./config');
var bodyParser = require('body-parser');
var CryptoJS = require('crypto-js');
var routes = require('./controllers/RouteController');
var utils = require('./utils/utils.js');

// Variables configuration.

var hasher = config.hasher;
var bytes = CryptoJS.AES.decrypt(config.appId.toString(), hasher);
var appId = bytes.toString(CryptoJS.enc.Utf8);
var bytesTwo = CryptoJS.AES.decrypt(config.masterKey.toString(), hasher);
var masterKey = bytesTwo.toString(CryptoJS.enc.Utf8);
var serverURL = config.serverURL;
var databaseUri = config.databaseUri;
var theClassNames = config.classNames;

// Parse Server configuration.

var api = new ParseServer({
  databaseURI: databaseUri,
  cloud: __dirname + '/cloud/main.js',
  appId: appId,
  masterKey: masterKey,
  serverURL: serverURL,
  liveQuery: { 
    classNames: theClassNames
  },
  verifyUserEmails: true,
  publicServerURL: serverURL,
  appName: 'WildcatConnect',
  emailAdapter: {
    module: 'parse-server-simple-mailgun-adapter',
    options: {
      fromAddress: 'team@wildcatconnect.org',
      domain: 'wildcatconnect.org',
      apiKey: 'key-21b93c07c71f9d42c7b0bec1fa68567f'
    }
  }
});

Parse.initialize(appId, masterKey);
Parse.serverURL = serverURL;

// Express app configuration.

var app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
  extended: true
}));

// Serve static assets from the /public folder

app.use(express.static(path.join(__dirname, '/public')));

// Configure routing.

app.use('/', routes);

// Serve the Parse API on the /Parse URL prefix

var mountPath = config.parseMount;
app.use(mountPath, api);

app.set('views', __dirname + '/views/pages');
app.set('view engine', 'ejs');

// POST requests.

app.post('/loggly', function(req, res) {
  winston.log('info', i);
  winston.log('info', req.body);
  res.end("Done!");
});

// HTTP configuration.

var port = process.env.PORT || 5000;
var httpServer = require('http').createServer(app);
httpServer.listen(port, function() {
    utils.log('info', 'Began client on port ' + port + '.', null);
});

// LiveQuery configuration.

ParseServer.createLiveQueryServer(httpServer);

let query = new Parse.Query("TestClass");
query.equalTo("testKey", "Here it is!!!");
let subscription = query.subscribe();

subscription.on('create', (objects) => {
  //Do something with this new object...
  console.log("Woop.");
});