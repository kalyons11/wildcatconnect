var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var PageModel = require('./page.js');

var page = new PageModel({
	title: "Forgot",
	configurations: {
		key: "Sample value."
	}
});

var forgotSchema = new Schema({
	object : {
		key: String
	},
	page : { type: mongoose.Schema.ObjectId, ref: 'Page' }
});

forgotSchema.methods.renderModel = function(data) {
	this.loadPageModel();
	this.initializeErrors();
};

forgotSchema.methods.loadPageModel = function() {
	this.page = page;
    this.page.loadPageModel();
};

forgotSchema.methods.initializeErrors = function() {
	this.page.theErrors = new Array();
}

var Forgot = mongoose.model('Forgot', forgotSchema);

module.exports = Forgot;