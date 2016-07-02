var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var PageModel = require('./page.js');

var page = new PageModel({
	title: "Test Page",
	configurations: {
		key: "Sample value."
	}
});

var testSchema = new Schema({
	object : {
		name: String,
		id: Number,
		data: {
			age: Number,
			link: String
		},
		created: Date,
		updated: Date,
		viewMode: { type: String, enum: [ 'get' , 'post' ]}
	},
	page : { type: mongoose.Schema.ObjectId, ref: 'Page' }
});

testSchema.methods.renderModel = function() {
	this.loadPageModel();
};

testSchema.methods.loadPageModel = function() {
	this.page = page;
};

var Test = mongoose.model('Test', testSchema);

module.exports = Test;