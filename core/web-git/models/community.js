var mongoose = require('mongoose');
var extend = require('mongoose-schema-extend');
var Schema = mongoose.Schema;
var utils = require('../utils/utils');
var moment = require('moment');
var CustomSchema = require('./custom').customSchema;

var commSchema = CustomSchema.extend({
	title: String,
	content: String,
	startDate: Date,
	endDate: Date
}, { collection: 'models' });

commSchema.methods.validateData = function(data) {
	var result = false;
	var message = "";
	utils.fillModel(this, data.body, "CommunityServiceStructure");
	var test = data.body.title != null && /\S/.test(data.body.title);
	if (! test) {
		message = "Title missing. Also, be sure you reselect any dates if necessary.";
		result = false;
		return { result: result , message: message, model: this };
	}
	test = data.body.content != null && /\S/.test(data.body.content);
	if (! test) {
		message = "Message missing. Also, be sure you reselect any dates if necessary.";
		result = false;
		return { result: result , message: message, model: this };
	}
	var startDate = moment(data.body.startDate);
	var endDate = moment(data.body.endDate);
	test = startDate.diff(moment(), "minutes") >= 0;
	if (! test) {
		message = "Start date occurs before today.";
		result = false;
		return { result: result , message: message, model: this };
	}
	test = endDate.diff(startDate, "minutes") >= 0;
	if (! test) {
		message = "End date occurs before start day.";
		result = false;
		return { result: result , message: message, model: this };
	}
	message = "Community service opportunity successfully submitted for approval. Please allow 1-2 days for processing.";
	result = true;
	return { result: result , message: message, model: this};
};

var CommunityServiceStructure = mongoose.model('CommunityServiceStructure', commSchema);

module.exports = CommunityServiceStructure;