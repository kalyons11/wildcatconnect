// Required for LiveQuery configuration.

"use strict";

// Modules configuration.

var express = require('express');

// Express app configuration.

var app = express();

// Serve static assets from the /public folder

app.use(express.static('public'));

app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

app.get("/:filename", function(req, res, next) {
  try {
    res.sendfile('/' + filename);
  } catch (e) {
    console.log(e);
    next();
  }
});

app.use(function(req, res) {
  res.status(404).send("Cannot find the requested resource.")
});

// HTTP configuration.

var port = process.env.PORT || 5000;
var httpServer = require('http').createServer(app);
httpServer.listen(port, function() {
    console.log('Began client on port ' + port + '.', null);
});