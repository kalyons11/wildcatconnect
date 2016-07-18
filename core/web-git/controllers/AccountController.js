var Parse = require('parse/node').Parse;
var Login = require('../models/login');
var Signup = require('../models/signup');
var Promise = require('promise');
var ApplicationMessage = require('../models/message');
var Classes = require('../utils/classes');
var utils = require('../utils/utils');

exports.authenticate = function(req, res, next) {
	if (Parse.User.current()) {
		next();
	} else {
		res.redirect('/app/login');
	}
};

exports.go = function(req, res) {
	res.redirect("/app/dashboard");
};

exports.getLogin = function(req, res) {
	Parse.User.logOut();
	var model = new Login();
	var data = { user: { auth: false } };
	model.renderModel(data);
	var session = Object.assign({ }, req.session);
	delete req.session.theErrors;
	res.render("login", { model: model, session: session });
};

exports.postLogin = function(req, res) {
	exports.tryLogin(req.body).then(function(response) {
		if (response.auth)
			res.redirect('/app/dashboard');
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
			delete req.session.theErrors;
			res.render("login", { model: model , session: null });
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

exports.getSignup = function(req, res) {
	var model = new Signup();
	model.renderModel(null);
	res.render("signup", { model: model, session: null });
};

exports.postSignup = function(req, res) {
	var model = new Signup();
	model.renderModel(req.body);
	if (model.page.theErrors.length > 0) {
		res.render("signup", { model: model, session: null });
	}
	else {
		exports.trySignup(req.body).then(function(response) {
			if (response.auth) {
				var model = new Login();
				var data = { user: { auth: false } };
				model.renderModel(data);

				var myError = new ApplicationMessage();
				myError.message = "You have successfully registered your WildcatConnect account! A member of administration will approve your request and you will then receive a confirmation e-mail.";
				myError.isError = false;
				model.page.theErrors.push(myError);
				req.session.theErrors = model.page.theErrors;
				res.redirect("/app/login");
			}
			else {
				var model = new Signup();
				model.renderModel(req.body);

				var rawError = new Error();
				var newBody = utils.removeParams(req.body);
				var error = response.error;
				if (error == null) {
					error = new ApplicationMessage;
					error.message = "User with these credentials already exists. Please try again.";
					error.isError = true;
				}
		        var x = utils.processError(error, rawError, [newBody]);
		        utils.log('error', x.message, { "stack" : x.stack , "objects" : x.objects });

				var myError = new ApplicationMessage();
				myError.message = x.message;
				myError.isError = true;
				model.page.theErrors.push(myError);
				res.render("signup", { model: model , session: null });
			}
		});
	}
};

exports.trySignup = function(data) {
	var user = new Parse.User();
	user.set("username", data.username);
	user.set("password", data.password);
	user.set("email", data.email);
	return new Promise(function(fulfill, reject) {
		var userRegisterStructure = Classes.UserRegisterStructure.initialize(data);
		Classes.UserRegisterStructure.validate(userRegisterStructure).then(function(response) {
			if (response.auth) {
				userRegisterStructure.save(null, {
					success: function(object) {
						fulfill({ auth: true });
					},
					error: function(error) {
						fulfill({ auth: false, error: error });
					}
				});
			} else {
				fulfill({ auth: false, error: response.error });
			}
		});	
	});
};