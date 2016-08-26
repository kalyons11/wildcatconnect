var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var PageModel = require('./page.js');
var utils = require("../utils/utils");

var page = new PageModel({
	title: "Test Page",
	configurations: {
		key: "Sample value."
	}
});

var denialSchema = new Schema({
	object : {
        name: String,
        message: String,
        title: String,
        admin: String,
        structureName: String
	},
	page : { type: mongoose.Schema.ObjectId, ref: 'Page' }
});

denialSchema.methods.renderModel = function(data, type) {
	this.loadPageModel();
    this.renderData(data, type);
};

denialSchema.methods.loadPageModel = function() {
	this.page = page;
    this.page.loadPageModel();
};

denialSchema.methods.renderData = function(data, type) {
    this.object = { };
    for (var key in data)
        this.object[key] = data[key];
    switch (type) {
        case "news":
            this.object.structureName = config.page.newsStructure;
            break;
        case "cs":
            this.object.structureName = "community service opportunity";
            break;
        case "event":
            this.object.structureName = "event";
            break;
    }
};

var Denial = mongoose.model('Denial', denialSchema);

module.exports = Denial;