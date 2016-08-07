var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var PageModel = require('./page.js');

var page = new PageModel({
	title: "Login",
	configurations: {
		key: "Sample value."
	}
});

var loginSchema = new Schema({
	object : {
		key: String
	},
	page : { type: mongoose.Schema.ObjectId, ref: 'Page' }
});

loginSchema.methods.renderModel = function(data) {
	this.loadPageModel();
	this.inititalizeUser(data.user);
	this.initializeErrors();
};

loginSchema.methods.loadPageModel = function() {
	this.page = page;
    this.page.loadPageModel();
};

loginSchema.methods.inititalizeUser = function(user) {
	this.page.user.auth = user.auth;
	if (this.page.user.auth) {
		this.page.user.username = user.username;
	};
}

loginSchema.methods.initializeErrors = function() {
	this.page.theErrors = new Array();
}

var Login = mongoose.model('Login', loginSchema);

module.exports = Login;