var Parse = require('parse/node').Parse;
var Forgot = require('../models/forgot');
var Promise = require('promise');
var ApplicationMessage = require('../models/message');
var utils = require('../utils/utils.js');

exports.getForgot = function(req, res) {
	var model = new Forgot();
	model.renderModel(null);
	res.render("forgot", { model: model });
};

exports.postForgot = function(req, res) {
	exports.tryForgot(req.body).then(function(response) {
		res.send(response);
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