var Parse = require('parse/node').Parse;
var utils = require('./utils');

var Classes = { };

Classes.UserRegisterStructure = Parse.Object.extend("UserRegisterStructure");

Classes.UserRegisterStructure.initialize = function(data) {
	var userRegisterStructure = new Parse.Object("UserRegisterStructure");
	userRegisterStructure.set("firstName", data.firstName);
	userRegisterStructure.set("lastName", data.lastName);
	userRegisterStructure.set("email", data.email);
	userRegisterStructure.set("username", data.username);
	var newPassword = utils.encrypt(data.password);
	userRegisterStructure.set("password", newPassword);
	var key = utils.generateKey();
	userRegisterStructure.set("key", key);
	return userRegisterStructure;
};

Classes.UserRegisterStructure.validate = function(object) {
	return new Promise(function(fulfill, reject) {
		var count = 0;
	  	var username = object.get("username");
	  	var email = object.get("email");
		var query = new Parse.Query("User");
		query.equalTo("username", username);
		query.find().then(function(usersA) {
		    count += usersA.length;
		    var queryFour = new Parse.Query("User");
		    queryFour.equalTo("email", email);
		    return queryFour.find();
		}).then(function(usersB) {
		    count += usersB.length;
		    var queryTwo = new Parse.Query("UserRegisterStructure");
		    query.equalTo("username", username);
		    return query.find();
		  }).then(function(usersC) {
		    count += usersC.length;
		    var queryThree = new Parse.Query("UserRegisterStructure");
		    queryThree.equalTo("email", email);
		    return queryThree.find();
		  }).then(function(usersD) {
		    count += usersD.length;
		    fulfill({ auth: (count == 0), error: null });
		  }), function(error) {
		    fulfill({ auth: false, error: error });
		  }
	});
};

module.exports = Classes;