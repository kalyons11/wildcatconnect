var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var PageModel = require('./page.js');
var ApplicationMessage = require('../models/message');
var utils = require('../utils/utils');

var page = new PageModel({
	title: "Register Account",
	configurations: {
		key: "Sample value."
	}
});

var signupSchema = new Schema({
	object : {
		firstName: String,
		lastName: String,
		email: String,
		username: String,
		password: String
	},
	page : { type: mongoose.Schema.ObjectId, ref: 'Page' }
});

signupSchema.methods.renderModel = function(data) {
	this.loadPageModel();
	this.initializeErrors();
	if (data != null) {
		var result = this.validateData(data);
	}		
};

signupSchema.methods.loadPageModel = function() {
	this.page = page;
};

signupSchema.methods.initializeErrors = function() {
	this.page.theErrors = new Array();
}

signupSchema.methods.validateData = function(data) {
	for (var key in data) {
		data[key] = data[key].trim();
	}
	utils.fillModel(this, data, "UserRegisterStructure");
	if (! data.firstName || ! data.lastName || ! data.email || ! data.emailConfirm || ! data.username || ! data.password || ! data.passwordConfirm) {
		var myError = new ApplicationMessage();
		myError.message = "Please ensure that you have completed all fields.";
		myError.isError = true;
		this.page.theErrors.push(myError);
		return false;
	} else if (data.email != data.emailConfirm) {
		var myError = new ApplicationMessage();
		myError.message = "E-mail fields do not match.";
		myError.isError = true;
		this.page.theErrors.push(myError);
		return false;
	} else if (data.password != data.passwordConfirm) {
		var myError = new ApplicationMessage();
		myError.message = "Password fields do not match.";
		myError.isError = true;
		this.page.theErrors.push(myError);
		return false;
	} else if (data.username.indexOf(" ") > -1) {
		var myError = new ApplicationMessage();
		myError.message = "Username cannot contain any spaces.";
		myError.isError = true;
		this.page.theErrors.push(myError);
		return false;
	} else if (data.password.indexOf(" ") > -1) {
		var myError = new ApplicationMessage();
		myError.message = "Password cannot contain any spaces.";
		myError.isError = true;
		this.page.theErrors.push(myError);
		return false;
	} else {
		return true;
	}
};

var Signup = mongoose.model('Signup', signupSchema);

module.exports = Signup;