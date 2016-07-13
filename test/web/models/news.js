var mongoose = require('mongoose');
var extend = require('mongoose-schema-extend');
var Schema = mongoose.Schema;
var utils = require('../utils/utils');
var moment = require('moment');
var CustomSchema = require('./custom').customSchema;

var newsSchema = CustomSchema.extend({
	title: String,
	author: String,
	date: String,
	summary: String,
	content: String,
	hasFiles: Boolean
}, { collection: 'models' });

newsSchema.methods.validateData = function(data) {
	var result = false;
	var message = "";
	utils.fillModel(this, data.body, "NewsArticleStructure");
	if (utils.doesFileExist(data)) {
		this.hasFiles = true;
	} else
		this.hasFiles = false;
	var test = data.body.title != null && /\S/.test(data.body.title);
	if (! test) {
		message = "Title missing.";
		result = false;
		return { result: result , message: message, model: this };
	}
	test = data.body.author != null && /\S/.test(data.body.author);
	if (! test) {
		message = "Author missing.";
		result = false;
		return { result: result , message: message, model: this};
	}
	test = theDate != null;
	if (! test) {
		message = "Date missing.";
		result = false;
		return { result: result , message: message, model: this };
	}
	test = data.body.summary != null && /\S/.test(data.body.summary);
	if (! test) {
		message = "Summary missing.";
		result = false;
		return { result: result , message: message, model: this};
	}
	test = data.body.content != null && /\S/.test(data.body.content);
	if (! test) {
		message = "Content missing.";
		result = false;
		return { result: result , message: message, model: this};
	}
	message = "Wildcat News Story successfully submitted for approval. Please allow 1-2 days for processing.";
	result = true;
	return { result: result , message: message, model: this};
};

var NewsArticleStructure = mongoose.model('NewsArticleStructure', newsSchema);

module.exports = NewsArticleStructure;