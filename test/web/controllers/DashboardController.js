var Parse = require('parse/node').Parse;
var Promise = require('promise');
var ApplicationMessage = require('../models/message');
var Classes = require('../utils/classes');
var utils = require('../utils/utils');
var moment = require('moment');
var Models = require('../models/models');

exports.authenticate = function(req, res) {
	if (Parse.User.current()) {
		var model = utils.initializeHomeUserModel(Parse.User.current());
		var path = "home";
		var action = null;
		exports.prepareDashboard(model, path, action);
		var session = Object.assign({ }, req.session);
		delete req.session.theErrors;
		res.render("main", { model: model, session: session });
	} else {
		res.redirect('/app/login');
	}
};

exports.processPost = function(req, res, path, action, data) {
	var obj = exports.validateData(path, action, data);
	if (obj.result == false) {
		var model = utils.initializeHomeUserModel(Parse.User.current());
		model.renderModel(path, action);
		model.customModel = obj.model;
		console.log(model);
		var myError = new ApplicationMessage();
		var message = obj.message;
		if (obj.model.hasFiles)
			message += " Also, we detected that you uploaded a file. Be sure to select file image again before submitting the form.";
		myError.message = message;
		myError.isError = true;
		model.page.theErrors.push(myError);
		req.session.theErrors = model.page.theErrors;
		if (model.customModel.type.indexOf("SettingsStructure") > -1 ) {
			return res.redirect("/app/dashboard/settings");
		}
		delete req.session.theErrors;
		return res.render("main", { model: model , session: null });
	} else {
		var model = utils.initializeHomeUserModel(Parse.User.current());
		model.renderModel("home", null);
		model.customModel = obj.model;
		utils.saveModel(model, { files: data.files }).then(function(response) {
			if (response.auth) {
				var model = utils.initializeHomeUserModel(Parse.User.current());
				model.renderModel("home", null);
				model.customModel = obj.model;
				var myError = new ApplicationMessage();
				myError.message = obj.message;
				myError.isError = false;
				model.page.theErrors.push(myError);
				req.session.theErrors = model.page.theErrors;
				if (model.customModel.type.indexOf("SettingsStructure") > -1 ) {
					res.redirect("/app/dashboard/settings");
				}
				else
					res.redirect("/app/dashboard");
			} else {
				var model = utils.initializeHomeUserModel(Parse.User.current());
				model.renderModel(path, action);
				model.customModel = obj.model;

				var newBody = utils.removeParams(req.body);
				var error = new Error();
				var x = utils.processError(response.error, error, [newBody]);
				utils.log('error', x.message, { "stack" : x.stack , "objects" : x.objects });

				var myError = new ApplicationMessage();
				myError.message = x.message;
				myError.isError = true;
				model.page.theErrors.push(myError);
				delete req.session.theErrors;
				res.render("main", { model: model , session: null });
			}
		});
	}
};

exports.handlePost = function(req, res, path, action) {
	var data = { body: req.body, files: req.files };
	return exports.processPost(req, res, path, action, data);
};

exports.route = function(req, res, next) {
	if (req.method == 'GET') {
		var path = req.params.path;
		var action = req.params.action;
		var model = utils.initializeHomeUserModel(Parse.User.current());
		exports.prepareDashboard(model, path, action);
		var session = Object.assign({ }, req.session);
		delete req.session.theErrors;
		if (model.doRender)
			return res.render("main", { model: model, session: session });
		else {
			next();
		}
	} else if (req.method == 'POST') {
		var path = req.params.path;
		var action = req.params.action;
		return exports.handlePost(req, res, path, action);
	}
};

exports.validateData = function(path, action, data) {
	var model = null;
	switch(path) {
		case "news":
			switch (action) {
				case "new":
					model = new Models.NewsArticleStructure();
					return model.validateData(data);
			}
		case "community":
			switch (action) {
				case "new":
					model = new Models.CommunityServiceStructure();
					return model.validateData(data);
			}
		case "event":
			switch (action) {
				case "new":
					model = new Models.EventStructure();
					return model.validateData(data);
			}
		case "group":
			switch (action){
				case "post":
					model = new Models.ExtracurricularUpdateStructure();
					return model.validateData(data);
			}
		case "settings":
			model = new Models.Settings();
			model.renderModel(action);
			return model.validateData(data);
	}
};

exports.prepareDashboard = function(model, path, action) {
	model.renderModel(path, action);
};