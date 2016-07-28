var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var ApplicationMessage = require('./message');

var pageSchema = new Schema({
	title: String,
	configurations : { },
	theErrors: [ApplicationMessage.schema],
	user: {
		auth: Boolean,
		username: String
	}
});

var PageModel = mongoose.model('Page', pageSchema);

module.exports = PageModel;