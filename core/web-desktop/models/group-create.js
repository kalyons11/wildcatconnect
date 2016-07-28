var mongoose = require('mongoose');
var extend = require('mongoose-schema-extend');
var Schema = mongoose.Schema;
var utils = require('../utils/utils');
var moment = require('moment');
var CustomSchema = require('./custom').customSchema;

var groupSchema = CustomSchema.extend({
    title: String,
    content: String
}, { collection: 'models' });

groupSchema.methods.validateData = function(data) {
    var result = false;
    var message = "";
    utils.fillModel(this, data.body, "ExtracurricularStructure");
    var test = data.body.title != null && /\S/.test(data.body.title);
    if (! test) {
        message = "Title missing.";
        result = false;
        return { result: result , message: message, model: this };
    }
    test = data.body.content != null && /\S/.test(data.body.content);
    if (! test) {
        message = "Message missing.";
        result = false;
        return { result: result , message: message, model: this };
    }
    message = "Group successfully created. You can now post updates to this group!";
    result = true;
    return { result: result , message: message, model: this};
};

var ExtracurricularStructure = mongoose.model('ExtracurricularStructure', groupSchema);

module.exports = ExtracurricularStructure;