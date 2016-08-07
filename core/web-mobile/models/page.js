var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var ApplicationMessage = require('./message');
var utils = require("../utils/utils");
var config = require('../config_enc');
config = utils.decryptObject(config);

var pageSchema = new Schema({
	title: String,
	configurations : { },
	theErrors: [ApplicationMessage.schema],
	user: {
		auth: Boolean,
		username: String
	}
});

pageSchema.methods.loadPageModel = function () {
    for (var key in config.page)
        this.configurations[key] = config.page[key];
};

var PageModel = mongoose.model('Page', pageSchema);

module.exports = PageModel;