var Parse = require('parse/node').Parse;
var Forgot = require('../models/forgot');
var Promise = require('promise');
var ApplicationMessage = require('../models/message');
var utils = require('../utils/utils.js');
var Models = require('../models/models');

exports.getForgot = function(req, res) {
	var model = new Forgot();
	model.renderModel(null);
	var session = Object.assign({ }, req.session);
	delete req.session.theErrors;
	res.render("forgot", { model: model, session : session });
};

exports.postForgot = function(req, res) {
	exports.tryForgot(req.body).then(function(response) {
		if (response.auth) {
			var model = new Models.Login();
			var data = { user: { auth: false } };
			model.renderModel(data);

			var myError = new ApplicationMessage();
			myError.message = "Please check your e-mail with instructions on how to reset your password.";
			myError.isError = false;
			model.page.theErrors.push(myError);
			req.session.theErrors = model.page.theErrors;
			res.redirect("/app/login");
		}
		else {
			try {
				var model = new Forgot();
				model.renderModel();

				var error = new Error();
		        var x = utils.processError(response.error, error, [ req.body ]);
		        utils.log('error', x.message, { "stack" : x.stack , "objects" : x.objects });

				var myError = new ApplicationMessage();
				myError.message = x.message;
				myError.isError = true;
				model.page.theErrors.push(myError);
				req.session.theErrors = model.page.theErrors;
				res.redirect("/app/forgot");
			} catch (e) {
				console.log(e);
			}
		}
	});
};

exports.tryForgot = function(data) {
	return new Promise(function(fulfill, reject) {
		Parse.User.requestPasswordReset(data.email, {
            success: function() {
            	var result = { auth : true , error: null };
            	fulfill(result);
            },
            error:function(error) {
                var result = { auth : false , error: error };
            	fulfill(result);
            }
        });
	});
};