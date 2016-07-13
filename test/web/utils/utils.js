var JSON = require('./JSON.js').JSON;
var winston = require('winston');
var config = require('../config');
var CryptoJS = require('crypto-js');
var Dashboard = require('../models/dashboard');
var Promise = require('promise');

var logglyToken = config.logglyToken;
var logglySubdomain = config.logglySubdomain;
var nodeTag = config.nodeTag;
var hasher = config.hasher;

require('winston-loggly');
 
winston.add(winston.transports.Loggly, {
    token: logglyToken,
    subdomain: logglySubdomain,
    tags: [nodeTag],
    json: true
});

module.exports.processError = function(realError, fakeError, objects) {
	/*
	 * processError
	 *
	 * Handles a client error and returns an object ready for logging.
	 *
	 * @param realError (Error) - Actual application error that threw exception.
	 * @param fakeError (Error) - Custom error declared to retreive stack information.
	 * @param objects (Array) - Array of relevant objects that should be included in JSON object for logging.
	 * 
	 * @return (JSON) - JSON of the following form - { message : messageString, stack = stackString, objects: objectsArray }.
	 */
	 var JSON = {};
	 JSON.message = module.exports.parseError(realError);
	 JSON.stack = fakeError.stack;
	 JSON.objects = module.exports.generateObjects(objects);
	 return JSON;
};

module.exports.parseError = function(error) {
	/*
	 * parseError
	 *
	 * Handles an error and returns a precise message/reason for the error based on its specified type.
	 *
	 * @param error (Error) - The error to be parsed.
	 * 
	 * @return (String) - String of error message.
	 */
	var errorType = module.exports.getObjectType(error);
	switch (errorType) {
		case "ParseError":
			return module.exports.removeLineBreaks(error.message);
		case "model":
			return error.message;
		default:
			return "Unable to extract error message for error." + error.toString();
	}
};

module.exports.generateObjects = function(objects) {
	/*
	 * generateObjects
	 *
	 * Generates JSON object with key objects, helping the above procesError method.
	 *
	 * @param objects (Array) - Objects to be parsed.
	 * 
	 * @return (JSON) - JSON object with key value pairs of form keyString : valueString.
	 */
	if (objects != null) {
		var theJSON = {};
		for (var i = 0; i < objects.length; i++) {
			var obj = objects[i];
			var type = module.exports.getObjectType(obj);
			theJSON[type] = JSON.stringify(obj);
		}
		return theJSON;
	} else
		return null;
};

module.exports.getObjectType = function(object) {
	/*
	 * getObjectType
	 *
	 * Gets type of object for the generateObjects keyString key.
	 *
	 * @param object (Object) - Object to be parsed.
	 * 
	 * @return (String) - String for the key.
	 */
	return object.constructor.name.toString();
};

module.exports.replaceAll = function(string, old, theNew) {
	/*
	 * replaceAll
	 *
	 * Replaces all occurances of "old" with "theNew" in "string".
	 *
	 * @param string (String) - The string undergoing editing here.
	 * @param old (String) - The string that will be replaced.
	 * @param theNew (String) - The string that replaces.
	 * 
	 * @return (String) - Final modified string.
	 */
	return string.replace(/old/g, theNew);
};

module.exports.removeLineBreaks = function(string) {
	/*
	 * removeLineBreaks
	 *
	 * Removes all unwanted line breaks in a given string.
	 *
	 * @param string (String) - The string undergoing editing here.
	 * 
	 * @return (String) - Final modified string.
	 */
	return string.replace(/\r?\n|\r/g, "");
};

module.exports.log = function(level, message, objects) {
	winston.log(level, message, objects);
}

module.exports.encrypt = function(string) {
	var result = CryptoJS.AES.encrypt(string, hasher);
	return result.toString();
}

module.exports.decrypt = function(string) {
	var bytes  = CryptoJS.AES.decrypt(string, hasher);
	var result = bytes.toString(CryptoJS.enc.Utf8);
	return result;
}

module.exports.generateKey = function() {
	var string = "";
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    for (var i = 0; i < 11; i++) {
        string += possible.charAt(Math.floor(Math.random() * possible.length));
    };
    return string;
};

module.exports.removeParams = function(object) {
	if (object.password != null)
		delete object.password;
	if (object.passwordConfirm != null)
		delete object.passwordConfirm;
	if (object.current != null)
		delete object.current;
	if (object.newPass != null)
		delete object.newPass;
	if (object.confirmNew != null)
		delete object.confirmNew;
	return object;
};

module.exports.initializeHomeUserModel = function(user) {
	var model = new Dashboard();
	if (user) {
		model.renderModel("Home", null);
		model.object.user.username = user.get("username");
		model.object.user.firstName = user.get("firstName");
		model.object.user.lastName = user.get("lastName");
		model.object.user.email = user.get("email");
		model.object.user.userType = user.get("userType");
		module.exports.determineHomeUserType(model);
		model.page.user.auth = true;
	} else {
		model.renderModel("error", null);
		model.page.user.auth = false;
	}
	return model;
};

module.exports.determineHomeUserType = function(model) {
	if (model.object.user.userType == "Developer") {
		model.object.user.isAdmin = true;
		model.object.user.isDeveloper = true;
	} else if (model.object.user.userType == "Administration") {
		model.object.user.isAdmin = true;
		model.object.user.isDeveloper = false;
	} else {
		model.object.user.isAdmin = false;
		model.object.user.isDeveloper = false;
	}
};

module.exports.fillModel = function(model, data, type) {
	model.type = type;
	if (type.indexOf("SettingsStructure") > -1) {
		for (var key in data) {
			model.data[key] = data[key];
		}
	} else if (type == "UserRegisterStructure") {
		for (var key in data) {
			model.object[key] = data[key];
		}
	} else {
		for (var key in data) {
			model[key] = data[key];
		}
	}
};

module.exports.saveModel = function(model, otherData) {
	return new Promise(function(fulfill, reject) {
		module.exports.convertToParseObject(model, otherData).then(function(response) {
			if (response.auth && response.save) {
				Parse.Cloud.run('saveGroupUpdates', { groupArray: response.objects }, {
					success: function(theResponse) {
						console.log(theResponse);
					},
					error: function(error) {
						console.log(error);
					}
				});
			} else if (response.auth) {
				fulfill({ auth: true });
			} else {
				fulfill({ auth: false , error: response.error });
			}
		});
	});
};

module.exports.convertToParseObject = function(model, otherData) {
	return new Promise(function(fulfill, reject) {
		var object = new Parse.Object(model.customModel.type);
		switch (model.customModel.type) {
			case "NewsArticleStructure":
				var hasFile = module.exports.doesFileExist(otherData);
				if (hasFile) {
					object.set("hasImage", 1);
					var name = otherData.files.image.name;
					var type = otherData.files.image.mimetype;
					var file = module.exports.generateParseFile(otherData.files.image.data, name, type);
					object.set("imageFile", file);
				} else {
					object.set("hasImage", 0);
				}
				object.set("titleString", model.customModel.title);
				object.set("authorString", model.customModel.author);
				object.set("dateString", model.customModel.date);
				object.set("summaryString", model.customModel.summary);
				object.set("contentURLString", model.customModel.content);
				object.set("likes", 0);
				object.set("views", 0);
				object.set("isApproved", 0);
				object.set("email", model.object.user.email);
				object.set("userString", module.exports.fullUserString(model));
				module.exports.getID(model).then(function(response) {
					if (response.auth) {
						object.set("articleID", response.ID);
						fulfill({ auth: true, objects: [ object ], save: true });
					} else {
						fulfill({ auth: false, error: response.error });
					}
				});
				break;
			case "CommunityServiceStructure":
				object.set("commTitleString", model.customModel.title);
				object.set("commSummaryString", model.customModel.content);
				object.set("startDate", new Date(model.customModel.startDate));
				object.set("endDate", new Date(model.customModel.endDate));
				object.set("isApproved", 0);
				object.set("email", model.object.user.email);
				object.set("userString", module.exports.fullUserString(model));
				module.exports.getID(model).then(function(response) {
					if (response.auth) {
						object.set("communityServiceID", response.ID);
						fulfill({ auth: true, objects: [ object ], save: true });
					} else {
						fulfill({ auth: false, error: response.error });
					}
				});
				break;
			case "EventStructure":
				object.set("titleString", model.customModel.title);
				object.set("locationString", model.customModel.location);
				object.set("messageString", model.customModel.content);
				object.set("eventDate", new Date(model.customModel.eventDate));
				object.set("isApproved", 0);
				object.set("email", model.object.user.email);
				object.set("userString", module.exports.fullUserString(model));
				module.exports.getID(model).then(function(response) {
					if (response.auth) {
						object.set("ID", response.ID);
						fulfill({ auth: true, objects: [ object ], save: true });
					} else {
						fulfill({ auth: false, error: response.error });
					}
				});
				break;
			case "ExtracurricularUpdateStructure":
				module.exports.getID(model).then(function(response) {
					if (response.auth) {
						var result = new Array();
						var i = 0;
						var startID = response.ID;
						while (i < model.customModel.finalUpdates.length) {
							var update = model.customModel.finalUpdates[i];
							var object = new Parse.Object(model.customModel.type);
							object.set("extracurricularID", parseInt(update.groupID));
							object.set("messageString", update.content);
							object.set("postDate", update.postDate);
							object.set("extracurricularUpdateID", startID);
							result.push(object);
							startID++;
							i++;
						}
						fulfill({ auth: true, objects: result, save: true });
					} else {
						fulfill({ auth: false, error: response.error });
					}
				});
				break;
			case "SettingsStructure.ChangePassword":
				Parse.User.requestPasswordReset(model.object.user.email, {
				  	success: function() {
				  		fulfill({ auth: true, save: false });
				  	},
				  	error: function(error) {
				    	fulfill({ auth: false, error: error });
				  	}
				});
				break;
			case "SettingsStructure.ChangeEmail":
				Parse.User.current().save({
					"email" : model.customModel.data.email
				}).then(function() {
					return Parse.User.current().fetch();
				}).then(function(finalUser) {
					fulfill({ auth: true, save: false });
				}, function(error) {
					fulfill({ auth: false, error: error });
				});
				break;
		}
	});
};

module.exports.generateParseFile = function(data, fileName, type) {
	var fileData = Array.prototype.slice.call(data, 0);
	var file = new Parse.File(fileName, fileData, type);
	return file;
}

module.exports.fullUserString = function(model) {
	return model.object.user.firstName + " " + model.object.user.lastName;
};

module.exports.doesFileExist = function(data) {
	return data.files.image.data.length > 0;
};

module.exports.getID = function(model) {
	return new Promise(function(fulfill, reject) {
		var query = new Parse.Query(model.customModel.type);
		switch (model.customModel.type) {
			case "NewsArticleStructure":
				query.descending("articleID");
	            query.first({
	                success: function(structure) {
	                    if (! structure) {
	                        fulfill({ auth: true, ID: 0 });
	                    } else {
	                    	var ID = structure.get("articleID") + 1;
	                    	fulfill({ auth: true, ID: ID });
	                    };
	                }, error: function(error) {
	                	fulfill({ auth: false, error: error });
	                }
	            });
	        	break;
	        case "CommunityServiceStructure":
				query.descending("communityServiceID");
	            query.first({
	                success: function(structure) {
	                    if (! structure) {
	                        fulfill({ auth: true, ID: 0 });
	                    } else {
	                    	var ID = structure.get("communityServiceID") + 1;
	                    	fulfill({ auth: true, ID: ID });
	                    };
	                }, error: function(error) {
	                	fulfill({ auth: false, error: error });
	                }
	            });
	            break;
	        case "EventStructure":
				query.descending("ID");
	            query.first({
	                success: function(structure) {
	                    if (! structure) {
	                        fulfill({ auth: true, ID: 0 });
	                    } else {
	                    	var ID = structure.get("ID") + 1;
	                    	fulfill({ auth: true, ID: ID });
	                    };
	                }, error: function(error) {
	                	fulfill({ auth: false, error: error });
	                }
	            });
	        	break;
	        case "ExtracurricularUpdateStructure":
	        	query.descending("extracurricularUpdateID");
	        	query.first({
	                success: function(structure) {
	                    if (! structure) {
	                        fulfill({ auth: true, ID: 0 });
	                    } else {
	                    	var ID = structure.get("extracurricularUpdateID") + 1;
	                    	fulfill({ auth: true, ID: ID });
	                    };
	                }, error: function(error) {
	                	fulfill({ auth: false, error: error });
	                }
	            });
		}
	});
};

module.exports.validatePassword = function(password) {
	var result = false;
	var message = "";
	var test = password.length >= 8;
	if (! test) {
		message = "Password must be at least 8 characters long.";
		result = false;
		return { result: result , message: message, model: this };
	}
	test = password.indexOf(" ");
	if (! test) {
		message = "Password cannot contain any spaces.";
		result = false;
		return { result: result , message: message, model: this };
	}
	message = "Validated.";
	result = true;
	return { result: result , message: message };
};

module.exports.escapeString = function(str) {
    return (str + '').replace(/[\\"']/g, '\\$&').replace(/\u0000/g, '\\0');
};