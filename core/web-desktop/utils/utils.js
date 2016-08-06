//region Module Imports...

var JSON = require('./JSON.js').JSON;
global.winston = require('winston');
var config = require('../config_enc');
var CryptoJS = require('crypto-js');
var Dashboard = require('../models/dashboard');
var Promise = require('promise');

var hasher = "dc4862c8-6a8b-49b4-a0e4-fe2bda364281";

module.exports.encrypt = function(string) {
    var result = CryptoJS.AES.encrypt(string, hasher);
    return result.toString();
};

module.exports.encryptObject = function (object) {
    var result = CryptoJS.AES.encrypt(JSON.stringify(object), hasher);
    return result.toString();
};

module.exports.decrypt = function(string) {
    var bytes  = CryptoJS.AES.decrypt(string, hasher);
    var result = bytes.toString(CryptoJS.enc.Utf8);
    result =  module.exports.trimQuotes(result);
    return result;
};

module.exports.decryptObject = function (string) {
    var bytes = CryptoJS.AES.decrypt(string, hasher);
    return JSON.parse(bytes.toString(CryptoJS.enc.Utf8));
};

module.exports.trimQuotes = function(string) {
    if (string.charAt(0) == '"')
        string = string.substring(1, string.length - 1);
    return string;
};

var config = module.exports.decryptObject(config);

var Mailgun = require('mailgun-js')({ apiKey: module.exports.decrypt(config.mailgunKey), domain: 'wildcatconnect.com'} );

var logglyToken = module.exports.decrypt(config.logglyToken);
var logglySubdomain = config.logglySubdomain;
var nodeTag = config.nodeTag;

require('winston-loggly');

winston.add(winston.transports.Loggly, {
    token: logglyToken,
    subdomain: logglySubdomain,
    tags: [nodeTag],
    json: true
});

//endregion

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
		    var message = module.exports.removeLineBreaks(error.message);
            if (message.indexOf("Unable to connect to the Parse API") > -1)
                return "Network error. Please ensure you are connected to the Internet.";
			else return message;
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
    console.log(message);
    console.log(objects);
	winston.log(level, message, objects);
};

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
		model.object.user.username = user["username"];
		model.object.user.firstName = user["firstName"];
		model.object.user.lastName = user["lastName"];
		model.object.user.email = user["email"];
		model.object.user.userType = user["userType"];
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

module.exports.fillParamaters = function(model, ID, otherData) {
	switch (model.customModel.type) {
        case "NewsArticleStructure":
            var result = { };
            if (model.customModel.hasFiles) {
                result.hasImage = 1;
                var name = otherData.files.image.name;
                var type = otherData.files.image.mimetype;
                var file = module.exports.generateParseFile(otherData.files.image.data, name, type);
                result.imageFile = file;
            } else
                result.hasImage = 0;
            result.articleID = ID;
            result.titleString = model.customModel.title;
            result.authorString = model.customModel.author;
            result.dateString = model.customModel.date;
            result.summaryString = model.customModel.summary;
            result.contentURLString = model.customModel.content;
            result.likes = 0;
            result.views = 0;
            result.isApproved = 0;
            result.email = model.object.user.email;
            result.userString = module.exports.fullUserString(model);
            return result;
        case "CommunityServiceStructure":
            var result = { };
            result.communityServiceID = ID;
            result.commTitleString = model.customModel.title;
            result.commSummaryString = model.customModel.content;
            result.startDate = new Date(model.customModel.startDate);
            result.endDate = new Date(model.customModel.endDate);
            result.isApproved = 0;
            result.email = model.object.user.email;
            result.userString = module.exports.fullUserString(model);
            return result;
        case "EventStructure":
            var result = { };
            result.ID = ID;
            result.titleString = model.customModel.title;
            result.locationString = model.customModel.location;
            result.messageString = model.customModel.content;
            result.eventDate = new Date(model.customModel.eventDate);
            result.isApproved = 0;
            result.email = model.object.user.email;
            result.userString = module.exports.fullUserString(model);
            return result;
        case "ExtracurricularUpdateStructure":
			return {
				"extracurricularUpdateID": ID,
				"content": model.customModel.content,
				"postDate": model.customModel.postDate,
				"finalUpdates": model.customModel.finalUpdates
	        };
        case "ExtracurricularStructure":
            return {
                "extracurricularID": ID,
                "titleString": model.customModel.title,
                "descriptionString": model.customModel.content,
                "userString": module.exports.fullUserString(model),
                "meetingIDs": "",
                "hasImage": 0
            };
        case "PollStructure":
            var result = { };
            result.pollID = ID;
            result.pollTitle = model.customModel.title;
            result.pollQuestion = model.customModel.question;
            result.pollMultipleChoices = model.customModel.finalChoices;
            result.daysActive = model.customModel.daysActive; // Must be integer for cloud code functionality...
            result.isActive = 1;
            result.totalResponses = 0;
            return result;
        case "ScholarshipStructure":
            return {
                "ID": ID,
                "titleString": model.customModel.title,
                "messageString": model.customModel.content,
                "dueDate": new Date(model.customModel.dueDate),
                "email": model.object.user.email,
                "userString": module.exports.fullUserString(model)
            };
        case "AlertStructure":
            var result = { };
            result.alertID = ID;
            result.titleString = model.customModel.title;
            result.authorString = module.exports.fullUserString(model);
            result.contentString = model.customModel.content;
            result.dateString = model.customModel.dateString;
            result.hasTime = model.customModel.hasTime ? 1 : 0;
            result.alertTime = model.customModel.hasTime ? new Date(model.customModel.theTime) : null;
            result.isReady = model.customModel.hasTime ? 0 : 1;
            result.views = 0;
            return result;
	}
};

module.exports.needCustomSaveOperation = function(model) {
    return model.customModel.type == "SettingsStructure.ChangePassword" || model.customModel.type == "SettingsStructure.ChangeEmail";
};

module.exports.customSaveOperation = function(model, req) {
    return new Promise(function(fulfill, reject) {
        switch (model.customModel.type) {
            case "SettingsStructure.ChangePassword":
                Parse.User.requestPasswordReset(model.object.user.email).then(function(error) {
                    fulfill({ auth: error != null, save: false, error: error });
                });
                break;
            case "SettingsStructure.ChangeEmail":
                Parse.Cloud.run("updateEmail", { username: req.session.user["username"], email: model.customModel.data.email }, {
                     success: function(response) {
                         req.session.user.email = model.customModel.data.email;
                         fulfill({ auth: true, save: false});
                     },
                     error: function (error) {
                         fulfill({ auth: false, save: false, error: error});
                     }
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

module.exports.getID = function(object) {
	return object != null ? parseInt(object.get(config.IDdictionary[object.className])) + 1 : 0;
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

module.exports.sendEmail = function(to, from, cc, bcc, subject, body, isHtml, res) {
    var data = { };
    data.from = from;
    data.to = to;
    if (cc)
        data.cc = cc;
    if (bcc)
        data.bcc = bcc;
    data.subject = subject;
    if (isHtml)
        data.html = body;
    else
        data.text = body;
    Mailgun.messages().send(data, function (err, body) {
        if (err && res != null) {
            res.send({res: err});
        }
    });
};

module.exports.verifyPage = function(model) {
    if (model.object.user.isDeveloper)
        return true;
    else if (model.object.user.isAdmin) {
        var key = model.page.configurations.key;
        return key.indexOf("dev") == -1;
    } else {
        // Faculty
        var key = model.page.configurations.key;
        var test = key.indexOf("poll") == -1 && key.indexOf("scholarship") == -1 && key.indexOf("alert") == -1 && key.indexOf("dev") == -1;
        test = test && key != "news.manage" && key != "event.manage" && key != "news.manage";
        test = test && key != "user.manage" && key != "schedule.manage" && key != "food.manage";
        return test;
    }
};