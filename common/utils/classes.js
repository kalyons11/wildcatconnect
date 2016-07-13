var Parse = require('parse/node').Parse;
var utils = require('./utils');

var Classes = { };

Classes.UserRegisterStructure = Parse.Object.extend("UserRegisterStructure", {
	create: function(data) {
		var userRegisterStructure = new Classes.UserRegisterStructure();
		userRegisterStructure.set("firstName", data.firstName);
		userRegisterStructure.set("lastName", data.lastName);
		userRegisterStructure.set("email", data.email);
		userRegisterStructure.set("username", data.username);
		var newPassword = utils.encrypt(data.password);
		console.log(newPassword);
		userRegisterStructure.set("password", data.password);
		userRegisterStructure.set("key", data.key);
		return userRegisterStructure;
	}
}):

module.exports = Classes;