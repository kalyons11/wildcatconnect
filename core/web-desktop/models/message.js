var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var messageSchema = new Schema({
	message: String,
	isError: Boolean
});

var ApplicationMessage = mongoose.model('ApplicationMessage', messageSchema);

module.exports = ApplicationMessage;

module.exports.schema = messageSchema;