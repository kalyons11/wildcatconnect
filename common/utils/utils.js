var JSON = require('./JSON.js').JSON;
var winston = require('winston');
var config = require('../config');
var CryptoJS = require('crypto-js');

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
	return object;
}