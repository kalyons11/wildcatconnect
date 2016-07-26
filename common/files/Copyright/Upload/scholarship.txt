var mongoose = require('mongoose');
var extend = require('mongoose-schema-extend');
var Schema = mongoose.Schema;
var utils = require('../utils/utils');
var moment = require('moment');
var CustomSchema = require('./custom').customSchema;

var scholSchema = CustomSchema.extend({
    title: String,
    content: String,
    dueDate: String
}, { collection: 'models' });

scholSchema.methods.validateData = function(data) {
    var result = false;
    var message = "";
    utils.fillModel(this, data.body, "ScholarshipStructure");
    var test = data.body.title != null && /\S/.test(data.body.title);
    if (! test) {
        message = "Title missing. Also, be sure to reselect any dates.";
        result = false;
        return { result: result , message: message, model: this };
    }
    test = data.body.content != null && /\S/.test(data.body.content);
    if (! test) {
        message = "Scholarship content missing. Also, be sure to reselect any dates.";
        result = false;
        return { result: result , message: message, model: this };
    }
    var theDate = moment(data.body.dueDate);
    test = theDate.diff(moment(), "days") >= 0;
    if (! test) {
        message = "Due date occurs before today.";
        result = false;
        return { result: result , message: message, model: this };
    }
    message = "Scholarship successfully submitted! It is now live on the iOS app.";
    result = true;
    return { result: result , message: message, model: this};
};scholSchema

var ScholarshipStructure = mongoose.model('ScholarshipStructure', scholSchema);

module.exports = ScholarshipStructure;