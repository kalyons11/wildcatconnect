var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var customSchema = new Schema({
	type: String
});

var CustomModel = mongoose.model('CustomModel', customSchema);

module.exports = CustomModel;
module.exports.customSchema = customSchema;