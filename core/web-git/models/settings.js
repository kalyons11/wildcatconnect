var mongoose = require('mongoose');
var extend = require('mongoose-schema-extend');
var Schema = mongoose.Schema;
var utils = require('../utils/utils');
var CustomSchema = require('./custom').customSchema;

var settingsSchema = CustomSchema.extend({
	action: String,
	data : { }
}, { collection: 'models' });

settingsSchema.methods.renderModel = function(action) {
	this.action = action;
	this.data = { };
};

settingsSchema.methods.validateData = function(data) {
	var result = false;
	var message = "";
	if (this.action == "changePassword") {
		utils.fillModel(this, data.body, "SettingsStructure.ChangePassword");
		result = true;
		message = "Password reset e-mail successfully sent.";
		return { result: result , message: message, model: this};
	} else if (this.action == "changeEmail") {
		utils.fillModel(this, data.body, "SettingsStructure.ChangeEmail");
		var test = data.body.email != null && /\S/.test(data.body.email);
		if (! test) {
			message = "E-mail field missing.";
			result = false;
			return { result: result , message: message, model: this };
		}
		test = data.body.email == Parse.User.current().get("email");
		if (test) {
			message = "This is your current e-mail address.";
			result = false;
			return { result: result , message: message, model: this };
		}
		result = true;
		message = "Account e-mail successfully updated. You will receive a verification e-mail to that address shortly.";
		return { result: result , message: message, model: this};
	}
};

var Settings = mongoose.model('Settings', settingsSchema);

module.exports = Settings;