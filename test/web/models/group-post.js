var mongoose = require('mongoose');
var extend = require('mongoose-schema-extend');
var Schema = mongoose.Schema;
var utils = require('../utils/utils');
var moment = require('moment');
var CustomSchema = require('./custom').customSchema;

var postSchema = CustomSchema.extend({
	groupID: String,
	content: String,
	postDate: Date,
	finalUpdates: [this]
}, { collection: 'models' });

postSchema.methods.validateData = function(data) {
	var result = false;
	var message = "";
	utils.fillModel(this, data.body, "ExtracurricularUpdateStructure");
	var test = data.body.groupArray != null && data.body.groupArray.length > 0;
	if (! test) {
		message = "You have not selected any groups for this update.";
		result = false;
		return { result: result , message: message, model: this };
	}
	test = data.body.content != null && /\S/.test(data.body.content);
	if (! test) {
		message = "Message missing.";
		result = false;
		return { result: result , message: message, model: this };
	}
	this.postDate = new Date(moment().format());
	this.finalUpdates = this.generateList(this, data.body.groupArray);
	message = "Group update successfully posted.";
	result = true;
	return { result: result , message: message, model: this};
};

postSchema.methods.generateList = function(group, array) {
	var returnArray = new Array();
	array = array.split(',');
	for (var i = 0; i < array.length; i++) {
		var structure = new ExtracurricularUpdateStructure();
		structure.content = group.content;
		structure.postDate = group.postDate;
		structure.groupID = array[i];
		returnArray.push(structure);
	}
	return returnArray;
}

var ExtracurricularUpdateStructure = mongoose.model('ExtracurricularUpdateStructure', postSchema);

module.exports = ExtracurricularUpdateStructure;