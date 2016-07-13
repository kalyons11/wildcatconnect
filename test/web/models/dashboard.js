var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var PageModel = require('./page.js');
var CustomModel = require('./custom.js');
var config = require('../config');
var utils = require('../utils/utils');

var page = new PageModel({
	title: "Home",
	configurations: {
		key: "Sample value.",
		view: "Sample key"
	}
});

var custom = new CustomModel({
	type: "No type yet."
});

var homeSchema = new Schema({
	object : {
		user : {
			username: String,
			firstName: String,
			lastName: String,
			email: String,
			userType: String,
			isAdmin: Boolean,
			isDeveloper: Boolean
		}
	},
	doRender: Boolean,
	page : { type: mongoose.Schema.ObjectId, ref: 'Page' },
	customModel : { type: mongoose.Schema.ObjectId, ref: 'CustomModel' }
});

homeSchema.methods.renderModel = function(path, action) {
	this.loadPageModel();
	this.loadCustomModel();
	this.initializeErrors();
	this.setValues(path, action);	
};

homeSchema.methods.setValues = function(path, action) {
	var title = "";
	var key = "";
	var renderError = false;
	switch (path) {
		case "home":
			title = "Home";
			break;
		case "news":
			switch (action) {
				case "new":
					title = "New Wildcat News Story";
					break;
				default:
					renderError = true;
					break;
			}
			break;
		case "community":
			switch (action) {
				case "new":
					title = "New Community Service";
					break;
				default:
					renderError = true;
					break;
			}
			break;
		case "event":
			switch (action) {
				case "new":
					this.loadConfigurations(path, action);
					title = "New Event";
					break;
				default:
					renderError = true;
					break;
			}
			break;
		case "group":
			switch (action) {
				case "post":
					this.loadConfigurations(path, action);
					title = "New Group Update";
					break;
				case "manage":
					this.loadConfigurations(path, action);
					title = "Manage Your Groups";
					break;
				default:
					renderError = true;
					break;
			}
			break;
		case "settings":
			title = "Settings";
			break;
		default:
			renderError = true;
			break;
	}
	if (action == null)
		key = path;
	else
		key = path + "." + action;
	this.page.title = title;
	this.page.configurations.key = key;
	this.doRender = ! renderError;
};

homeSchema.methods.loadPageModel = function() {
	this.page = page;
};

homeSchema.methods.loadCustomModel = function() {
	this.customModel = custom;
};

homeSchema.methods.initializeErrors = function() {
	this.page.theErrors = new Array();
};

homeSchema.methods.loadConfigurations = function(path, action) {
	switch (path) {
		case "group":
			switch (action) {
				case "post":
					this.parseConfig();
					break;
				case "manage":
					this.parseConfig();
					break;
			}
			break;
	}
};

homeSchema.methods.parseConfig = function() {
	var appId = utils.decrypt(config.appId);
	var masterKey = utils.decrypt(config.masterKey);
	this.page.configurations.appId = appId;
	this.page.configurations.masterKey = masterKey;
	this.page.configurations.serverURL = config.serverURL;
};

var Dashboard = mongoose.model('Dashboard', homeSchema);

module.exports = Dashboard;