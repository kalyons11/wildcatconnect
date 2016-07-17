// Required for LiveQuery configuration.

"use strict";

// Modules configuration.

var express = require('express');
var ParseServer = require('parse-server').ParseServer;
var path = require('path');
var Parse = require('parse/node').Parse;
var config = require('./config');
var CryptoJS = require('crypto-js');
var routes = require('./controllers/RouteController');
var utils = require('./utils/utils.js');
var cookieParser = require('cookie-parser');
var session = require('express-session');
var moment = require('moment');
var busboy = require('busboy-body-parser');
var bodyParser = require('body-parser');
var S3Adapter = require('parse-server').S3Adapter;
var Models = require('./models/models');
var cors = require('cors');

var SimpleMailgunAdapter = require('./utils/SimpleMailgunAdapter');
var simpleMailgunAdapter = new SimpleMailgunAdapter({
  apiKey: 'key-21b93c07c71f9d42c7b0bec1fa68567f',
  domain: 'wildcatconnect.org',
  fromAddress: 'team@wildcatconnect.org'
});

// Variables configuration.

var hasher = config.hasher;
var bytes = CryptoJS.AES.decrypt(config.appId.toString(), hasher);
var appId = bytes.toString(CryptoJS.enc.Utf8);
var bytesTwo = CryptoJS.AES.decrypt(config.masterKey.toString(), hasher);
var masterKey = bytesTwo.toString(CryptoJS.enc.Utf8);
var serverURL = config.serverURL;
var databaseUri = config.databaseUri;
var theClassNames = config.classNames;
var secret = config.secret;

// Uncaught exceptions.

process.on('uncaughtException', (error) => {
  var rawError = new Error();
  var x = utils.processError(error, rawError, null);
  utils.log('error', x.message, { "stack" : x.stack , "objects" : x.objects });
});

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
  emailAdapter: simpleMailgunAdapter,
  filesAdapter: new S3Adapter(
    "AKIAJZ2KYD7RZL2UKD3A",
    "H+vd9D2b79dR4PNeUYVwjUQms6ZdMMegnYgqTmyM",
    "test-wc-bucket",
    { directAccess: true }
  )
});

Parse.initialize(appId, masterKey);
Parse.serverURL = serverURL;

// Express app configuration.

var app = express();

app.use(busboy());
app.use(bodyParser.json());

// Session configuration.

app.use(cookieParser());
app.use(session({ secret: secret, resave: true, saveUninitialized: true }));

// Serve static assets from the /public folder

app.use(express.static('public'));

// Handle local variables...

app.use(cors());

app.use(function(req, res, next) {
  res.locals.moment = moment;
  next();
});

// Serve the Parse API on the /Parse URL prefix

var mountPath = config.parseMount;
app.use(mountPath, api);

// Configure routing

app.use(bodyParser.urlencoded({ extended: true }));

app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

app.use('/', routes);

app.use(function(req, res, next) {
  utils.log('error', "Page not found.", { url: req.url });
  var model = utils.initializeHomeUserModel(Parse.User.current());
  model.page.title = "Not Found";
  model.error = {
    url: req.url,
    code: 404
  };
  res.status(404).render("error", { model: model });
});

app.set('views', __dirname + '/views/pages');
app.set('view engine', 'ejs');

// HTTP configuration.

var port = process.env.PORT || 5000;
var httpServer = require('http').createServer(app);
httpServer.listen(port, function() {
    console.log('Began client on port ' + port + '.', null);
    /*var object = new Parse.Object("ExtracurricularUpdateStructure");
    object.set("titleString", "My Group Two");
    object.set("descriptionString", "Here it is!");
    object.set("hasImage", 0);
    object.set("imageFile", null);
    object.set("extracurricularID", 1);
    object.set("meetingIDs", "");
    object.set("userString", "Kevin Lyons");
    object.save(null, {
      success: function(object) {
        console.log("We did it!!");
      }
    });*/
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