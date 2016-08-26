// Module configuration.

var express = require('express');
var router = express.Router();
var utils = require('../utils/utils');
var Models = require('../models/models');
var config = global.config;

// Controller configuration.

var AccountController = require('./AccountController');
var ForgotController = require('./ForgotController');
var DashboardController = require('./DashboardController');
var JobController = require('./JobController');

var pages = config.pages;

/*pages = pages.substring(1, pages.length - 1);

pages = utils.replaceAll(pages, " ", "");

pages = pages.split(", ");

for (var i = 0; i < pages.length; i++) {
    pages[i] = pages[i].substring(1, pages[i].length - 1);
}*/

router.get(pages, function(req, res) {
    utils.log('error', "Unauthorized request.", { url: req.url });
    var model = utils.initializeHomeUserModel(req.session.user);
    model.page.title = "Unauthorized";
    model.error = {
        url: req.url,
        code: 401
    };
    res.status(401).render("error", { model: model });
});

router.get('/', DashboardController.home);

router.post('/:action', DashboardController.homePost);

router.get('/app', function(req, res) {
    res.redirect("/app/dashboard");
});

router.get('/app/login', AccountController.getLogin);
router.post('/app/login', AccountController.postLogin);

router.get('/app/signup', AccountController.getSignup);
router.post('/app/signup', AccountController.postSignup);

router.get('/app/forgot', ForgotController.getForgot);
router.post('/app/forgot', ForgotController.postForgot);

router.get('/app/verify', AccountController.getVerify);
router.post('/app/verify', AccountController.postVerify);

router.all('/app/*', AccountController.authenticate, function(req, res, next) {
	next();
});

router.post('/app/dashboard/:path/:action/ajax/:request', DashboardController.custom);

router.post('/app/dashboard/:action', DashboardController.mainPost);

router.get('/app/dashboard', DashboardController.authenticate);

router.all(['/app/dashboard/:path', '/app/dashboard/:path/:action', '/app/dashboard/:path/:action/:subaction'], DashboardController.route);

router.get('/download/ios', function(req, res) {
    var link = config.page.iosUrl;
    res.redirect(link);
});

router.post('/job/:name', JobController.handleJob);

module.exports = router;