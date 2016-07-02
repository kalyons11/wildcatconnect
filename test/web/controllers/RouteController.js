// Module configuration.

var express = require('express');
var router = express.Router();

// Controller configuration.

var TestController = require('./TestController');
var AccountController = require('./AccountController');
var ForgotController = require('./ForgotController');

router.get('/test', TestController.view);
router.post('/test', TestController.post);

router.get('/', AccountController.authenticate);
router.get('/login', AccountController.getLogin);
router.post('/login', AccountController.postLogin);

router.get('/forgot', ForgotController.getForgot);
router.post('/forgot', ForgotController.postForgot);

module.exports = router;