var JSON = require('./JSON.js').JSON;

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
	 var message = module.exports.parseError(realError);
	 var stack = fakeError.stack;
	 var objects = module.exports.generateObjects(objects);
	 var JSON = {};
	 JSON.message = message;
	 JSON.stack = stack;
	 JSON.objects = objects;
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
	var theJSON = {};
	for (var i = 0; i < objects.length; i++) {
		var obj = objects[i];
		var type = module.exports.getObjectType(obj);
		theJSON[type] = JSON.stringify(obj);
	}
	return theJSON;
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
	return string.replace(/old/g, theNew);
};

module.exports.removeLineBreaks = function(string) {
	return string.replace(/\r?\n|\r/g, "");
};