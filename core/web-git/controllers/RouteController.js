// Module configuration.

var express = require('express');
var router = express.Router();
var config = require('../config');
var utils = require('../utils/utils');
var Models = require('../models/models');

// Controller configuration.

var AccountController = require('./AccountController');
var ForgotController = require('./ForgotController');
var DashboardController = require('./DashboardController');

var pages = config.pages;

router.get(pages, function(req, res) {
    utils.log('error', "Unauthorized request.", { url: req.url });
    var model = utils.initializeHomeUserModel(Parse.User.current());
    model.page.title = "Unauthorized";
    model.error = {
        url: req.url,
        code: 401
    };
    res.status(401).render("error", { model: model });
});

router.get('/app', function(req, res) {
    res.redirect("/app/dashboard");
});

router.get('/app/login', AccountController.getLogin);
router.post('/app/login', AccountController.postLogin);
router.get('/app/signup', AccountController.getSignup);
router.post('/app/signup', AccountController.postSignup);

router.get('/app/forgot', ForgotController.getForgot);
router.post('/app/forgot', ForgotController.postForgot);

router.post('/app/dashboard/:path/:action/ajax/:request', DashboardController.custom);

router.all('/app/*', AccountController.authenticate, function(req, res, next) {
	next();
});

router.get('/app/dashboard', DashboardController.authenticate);
router.all(['/app/dashboard/:path', '/app/dashboard/:path/:action', '/app/dashboard/:path/:action/:subaction'], DashboardController.route);

module.exports = router;