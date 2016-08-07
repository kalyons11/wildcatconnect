var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var PageModel = require('./page.js');
var CustomModel = require('./custom.js');
var utils = require("../utils/utils");
var config = require("../config_enc");
config = utils.decryptObject(config);

var page = new PageModel({
	title: "Home",
	configurations: { }
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

homeSchema.methods.renderModel = function(path, action, subaction) {
	this.loadPageModel();
	this.loadCustomModel();
	this.initializeErrors();
	this.setValues(path, action, subaction);
};

homeSchema.methods.setValues = function(path, action, subaction) {
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
					title = "New " + config.page.newsStructure;
					break;
                case "manage":
                    title = "Manage News Stories";
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
                case "manage":
                    title = "Manage Community Service";
                    break;
				default:
					renderError = true;
					break;
			}
			break;
		case "event":
			switch (action) {
				case "new":
					title = "New Event";
					break;
                case "manage":
                    title = "Manage Events";
                    break;
				default:
					renderError = true;
					break;
			}
			break;
		case "group":
			switch (action) {
				case "post":
					title = "New Group Update";
					break;
				case "manage":
				    if (subaction == "create") {
                        title = "Create New Group";
                    }
                    else
					    title = "Manage Groups";
					break;
				default:
					renderError = true;
					break;
			}
			break;
        case "poll":
            switch (action) {
                case "manage":
                    title = "Manage User Polls";
                    break;
                case "new":
                    title = "New User Poll";
                    break;
            }
            break;
        case "scholarship":
            switch (action) {
                case "manage":
                    title = "Manage Scholarships";
                    break;
                case "new":
                    title = "New Scholarship";
                    break;
            }
            break;
        case "alert":
            switch (action) {
                case "manage":
                    title = "Manage Alerts";
                    break;
                case "new":
                    title = "New Alert";
                    break;
                if (subaction != null){
                    switch (subaction) {
                        case "edit":
                            title = "Edit Alert";
                            break;
                    }
                }
            }
            break;
        case "user":
            switch (action) {
                case "manage":
                    title = "Manage Users";
                    break;
            }
            break;
        case "schedule":
            switch (action) {
                case "manage":
                    title = "Manage Schedule";
                    break;
            }
            break;
        case "food":
            switch (action) {
                case "manage":
                    title = "Manage Food";
                    break;
            }
            break;
        case "dev":
            switch (action) {
                case "manage":
                    title = "Manage Application";
                    break;
                case "links":
                    title = "Manage Links";
                    break;
                case "console":
                    title = "Developer Console";
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
	else if (subaction == null)
		key = path + "." + action;
    else
        key = path + "." + action + "." + subaction;
	this.page.title = title;
	this.page.configurations.key = key;
	this.doRender = ! renderError;
};

homeSchema.methods.loadPageModel = function() {
    this.page = page;
	this.page.loadPageModel();
};

homeSchema.methods.loadCustomModel = function() {
	this.customModel = custom;
};

homeSchema.methods.initializeErrors = function() {
	this.page.theErrors = new Array();
};

var Dashboard = mongoose.model('Dashboard', homeSchema);

module.exports = Dashboard;