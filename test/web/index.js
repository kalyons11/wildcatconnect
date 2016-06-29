// Required for LiveQuery configuration.

"use strict";

// Modules configuration.

var express = require('express');
var ParseServer = require('parse-server').ParseServer;
var path = require('path');
var parse = require('parse').Parse;
var config = require('./config');
var bodyParser = require('body-parser');
var utils = require('./utils/utils.js');
var CryptoJS = require('crypto-js');

// Variables configuration.

var hasher = config.hasher;
var bytes = CryptoJS.AES.decrypt(config.appId.toString(), hasher);
var appId = bytes.toString(CryptoJS.enc.Utf8);
var bytesTwo = CryptoJS.AES.decrypt(config.masterKey.toString(), hasher);
var masterKey = bytesTwo.toString(CryptoJS.enc.Utf8);
var serverURL = config.serverURL;
var databaseUri = config.databaseUri;
var logglyToken = config.logglyToken;
var logglySubdomain = config.logglySubdomain;
var nodeTag = config.nodeTag;
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
  }
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

// Express app configuration.

var app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
  extended: true
}));

// Serve static assets from the /public folder

app.use(express.static(path.join(__dirname, '/public')));

// Serve the Parse API on the /parse URL prefix

var mountPath = config.parseMount;
app.use(mountPath, api);

app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

// GET requests.

app.get('/', function(req, res) {
  res.status(200).render("test", { key : { key2 : "The value!!!" } });
  Parse.initialize(appId, masterKey);
  Parse.serverURL = serverURL;
  var millisecondsToWait = 5000;
  setTimeout(function() {
    var obj = new Parse.Object("TestClass");
    obj.set("testKey", "Here it is!!!");
    obj.set("newKey", "Here we go.");
    obj.save(null, {
      success: function(savedObject) {
        winston.log('info', savedObject);
      },
      error: function(error) {
        var error = new Error();
        var x = utils.processError(newError, error, [ query ]);
        winston.log('error', x.message, { "stack" : x.stack , "objects" : x.objects });
      }
    });
  }, millisecondsToWait);
});

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
    winston.log('info', 'Began client on port ' + port + '.');
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