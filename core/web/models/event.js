var mongoose = require('mongoose');
var extend = require('mongoose-schema-extend');
var Schema = mongoose.Schema;
var utils = require('../utils/utils');
var moment = require('moment');
var CustomSchema = require('./custom').customSchema;

var eventSchema = CustomSchema.extend({
	title: String,
	location: String,
	eventDate: Date,
	content: String
}, { collection: 'models' });

eventSchema.methods.validateData = function(data, user) {
	var result = false;
	var message = "";
	utils.fillModel(this, data.body, "EventStructure");
	var test = data.body.title != null && /\S/.test(data.body.title);
	if (! test) {
		message = "Title missing. Also, be sure you reselect any dates if necessary.";
		result = false;
		return { result: result , message: message, model: this };
	}
	test = data.body.location != null && /\S/.test(data.body.location);
	if (! test) {
		message = "Message missing. Also, be sure you reselect any dates if necessary.";
		result = false;
		return { result: result , message: message, model: this };
	}
	test = data.body.content != null && /\S/.test(data.body.content);
	if (! test) {
		message = "Message missing. Also, be sure you reselect any dates if necessary.";
		result = false;
		return { result: result , message: message, model: this };
	}
	var eventDate = moment(data.body.eventDate);
	test = eventDate.diff(moment(), "minutes") >= 0;
	if (! test) {
		message = "Start date occurs before now.";
		result = false;
		return { result: result , message: message, model: this };
	}
    if (utils.hasAdminLevel(user))
        message = "Event successfully posted to the application.";
    else
        message = "Event successfully submitted for approval. Please allow 1-2 days for processing.";
	result = true;
	return { result: result , message: message, model: this};
};

var EventStructure = mongoose.model('EventStructure', eventSchema);

module.exports = EventStructure;