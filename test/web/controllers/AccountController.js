var Parse = require('parse/node').Parse;
var Login = require('../models/login');
var Promise = require('promise');
var ApplicationMessage = require('../models/message');
var utils = require('../utils/utils.js');

exports.authenticate = function(req, res) {
	if (Parse.User.current()) {
		res.redirect('/home');
	} else {
		res.redirect('/login');
	}
};

exports.getLogin = function(req, res) {
	var model = new Login();
	var data = { user: { auth: false } };
	model.renderModel(data);
	res.render("login", { model: model });
};

exports.postLogin = function(req, res) {
	exports.tryLogin(req.body).then(function(response) {
		if (response.auth)
			console.log("We're in!");
		else {
			var model = new Login();
			var data = { user: { auth: false } };
			model.renderModel(data);

			var error = new Error();
	        var x = utils.processError(response.error, error, null);
	        utils.log('error', x.message, { "stack" : x.stack , "objects" : x.objects });

			var myError = new ApplicationMessage();
			myError.message = x.message;
			myError.isError = true;
			model.page.theErrors.push(myError);
			res.render("login", { model: model });
		}
	});
};

exports.tryLogin = function(user) {
	return new Promise(function(fulfill, reject) {
		Parse.User.logIn(user.username, user.password, {
			success: function(newUser) {
				fulfill({ auth: true  });
			},
			error: function(sorryUser, error) {
				fulfill({ auth: false , error: error });
			}
		});
	});
};