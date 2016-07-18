var mongoose = require('mongoose');
var extend = require('mongoose-schema-extend');
var Schema = mongoose.Schema;
var utils = require('../utils/utils');
var moment = require('moment');
var CustomSchema = require('./custom').customSchema;

var alertSchema = CustomSchema.extend({
    title: String,
    dateString: String,
    content: String,
    theTime: Date,
    hasTime: Boolean
}, { collection: 'models' });

alertSchema.methods.validateData = function(data) {
    var result = false;
    var message = "";
    utils.fillModel(this, data.body, "AlertStructure");
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
    this.hasTime = data.body.alertTiming == 'time';
    if (this.hasTime) {
        var theDate = new Date(data.body.theTime);
        var time = moment(theDate);
        test = time.diff(moment(), "minutes") >= 0;
        if (! test) {
            message = "Alert date occurs before now.";
            result = false;
            return { result: result , message: message, model: this };
        }
        this.dateString = time.format("dddd, MMMM Do @ h:mm A");
    } else {
        this.dateString = moment().format("dddd, MMMM Do @ h:mm A");
    }
    message = ! this.hasTime ? "Alert successfully posted." : "Alert will be released to the app at your selected date - " + this.dateString + ".";
    result = true;
    return { result: result , message: message, model: this};
};

var AlertStructure = mongoose.model('AlertStructure', alertSchema);

module.exports = AlertStructure;