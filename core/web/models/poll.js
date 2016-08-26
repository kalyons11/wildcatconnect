var mongoose = require('mongoose');
var extend = require('mongoose-schema-extend');
var Schema = mongoose.Schema;
var utils = require('../utils/utils');
var moment = require('moment');
var CustomSchema = require('./custom').customSchema;

var pollSchema = CustomSchema.extend({
    title: String,
    question: String,
    daysActive: String,
    finalChoices: { },
    rawChoices: String
}, { collection: 'models' });

pollSchema.methods.validateData = function(data) {
    var result = false;
    var message = "";
    utils.fillModel(this, data.body, "PollStructure");
    this.rawChoices = data.body.finalChoices;
    var test = data.body.title != null && /\S/.test(data.body.title);
    if (! test) {
        message = "Title missing.";
        result = false;
        return { result: result , message: message, model: this };
    }
    test = data.body.question != null && /\S/.test(data.body.question);
    if (! test) {
        message = "Question missing.";
        result = false;
        return { result: result , message: message, model: this };
    }
    test = data.body.daysActive != null && parseInt(data.body.daysActive) > 0;
    if (! test) {
        message = "Must select number of days poll is active.";
        result = false;
        return { result: result , message: message, model: this };
    }
    test = data.body.finalChoices != null && data.body.daysActive.length > 0;
    if (! test) {
        message = "Must enter poll choices.";
        result = false;
        return { result: result , message: message, model: this };
    }
    test = data.body.numberSelect != null && data.body.numberSelect > 1;
    if (! test) {
        message = "Must choose at least 2 poll choices.";
        result = false;
        return { result: result , message: message, model: this };
    }
    this.finalChoices = this.generateChoices(data.body.finalChoices);
    message = "User poll successfully submitted! It is now live on the iOS app.";
    result = true;
    return { result: result , message: message, model: this};
};

pollSchema.methods.generateChoices = function(string) {
    var array = string.split(',');
    var object = { };
    for (var i = 0; i < array.length; i++) {
        object[array[i]] = 0;
    }
    return object;
};

var PollStructure = mongoose.model('PollStructure', pollSchema);

module.exports = PollStructure;