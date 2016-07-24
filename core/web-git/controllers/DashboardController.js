var Parse = require('parse/node').Parse;
var Promise = require('promise');
var ApplicationMessage = require('../models/message');
var Classes = require('../utils/classes');
var utils = require('../utils/utils');
var moment = require('moment');
var Models = require('../models/models');
var config = require('../config_enc');
config = utils.decryptObject(config);
var AccountController = require("./AccountController");

exports.authenticate = function(req, res) {
	if (Parse.User.current()) {
		var model = utils.initializeHomeUserModel(Parse.User.current());
		var path = "home";
		var action = null;
		exports.prepareDashboard(model, path, action);
		var session = Object.assign({ }, req.session);
		delete req.session.theErrors;
		res.render("main", { model: model, session: session });
	} else {
		res.redirect('/app/login');
	}
};

exports.processPost = function(req, res, path, action, subaction, data) {
	var obj = exports.validateData(path, action, subaction, data);
	if (obj.result == false) {
		var model = utils.initializeHomeUserModel(Parse.User.current());
		model.renderModel(path, action, subaction);
		model.customModel = obj.model;
		var myError = new ApplicationMessage();
		var message = obj.message;
		if (obj.model.hasFiles)
			message += " Also, we detected that you uploaded a file. Be sure to select file image again before submitting the form.";
		myError.message = message;
		myError.isError = true;
		model.page.theErrors.push(myError);
		req.session.theErrors = model.page.theErrors;
		if (model.customModel.type.indexOf("SettingsStructure") > -1 ) {
			return res.redirect("/app/dashboard/settings");
		}
		delete req.session.theErrors;
		return res.render("main", { model: model , session: null });
	} else {
		var model = utils.initializeHomeUserModel(Parse.User.current());
		model.renderModel("home", null);
		model.customModel = obj.model;
		return exports.saveModel(model, req, res, obj.message, path, action, subaction);
	}
};

exports.saveModel = function(model, req, res, message, path, action, subaction) {
    if (utils.needCustomSaveOperation(model)) {
        utils.customSaveOperation(model).then(function (response) {
            return exports.handleSave(model, response.error, req, res, message, path, action, subaction);
        });
    } else {
        var query = new Parse.Query(model.customModel.type);
        query.descending(config.IDdictionary[model.customModel.type]);
        query.first().then(function(theFirst) {
            var promiseInner = Parse.Promise.as();
            promiseInner = promiseInner.then(function() {
                var ID = utils.getID(theFirst);
                var otherData = { files: req.files };
                var params = utils.fillParamaters(model, ID, otherData);
                var object = new Parse.Object(model.customModel.type);
                object.save(params).then(function(theObject, error) {
                    return exports.handleSave(model, error, req, res, message, path, action, subaction);
                });
            });
        });
    }
};

exports.handleSave = function(theModel, error, req, res, message, path, action, subaction) {
	if (error == null) {
		var model = utils.initializeHomeUserModel(Parse.User.current());
		model.renderModel("home", null);
		model.customModel = theModel.customModel;
		var myError = new ApplicationMessage();
		myError.message = message;
		myError.isError = false;
		model.page.theErrors.push(myError);
		req.session.theErrors = model.page.theErrors;
		if (model.customModel.type.indexOf("SettingsStructure") > -1 ) {
			res.redirect("/app/dashboard/settings");
		}
		else
			res.redirect("/app/dashboard");
	} else {
		var model = utils.initializeHomeUserModel(Parse.User.current());
		model.renderModel(path, action, subaction);
		model.customModel = theModel.customModel;

		var newBody = utils.removeParams(req.body);
		var error = new Error();
		var x = utils.processError(response.error, error, [newBody]);
		utils.log('error', x.message, { "stack" : x.stack , "objects" : x.objects });

		var myError = new ApplicationMessage();
		myError.message = x.message;
		myError.isError = true;
		model.page.theErrors.push(myError);
		delete req.session.theErrors;
		res.render("main", { model: model , session: null });
	}
};

exports.handlePost = function(req, res, path, action, subaction) {
	var data = { body: req.body, files: req.files };
	return exports.processPost(req, res, path, action, subaction, data);
};

exports.route = function(req, res, next) {
	if (req.method == 'GET') {
		var path = req.params.path;
		var action = req.params.action;
        var subaction = req.params.subaction;
		var model = utils.initializeHomeUserModel(Parse.User.current());
		exports.prepareDashboard(model, path, action, subaction);
		var session = Object.assign({ }, req.session);
		delete req.session.theErrors;
		if (model.doRender)
			return res.render("main", { model: model, session: session });
		else {
			next();
		}
	} else if (req.method == 'POST') {
		var path = req.params.path;
		var action = req.params.action;
        var subaction = req.params.subaction;
		return exports.handlePost(req, res, path, action, subaction);
	}
};

exports.custom = function (req, res) {
    var path = req.params.path;
    var action = req.params.action;
    var request = req.params.request;
    if (path == "group" && action == "post" && request == "load") {
        var queryOne = new Parse.Query(Parse.User);
        queryOne.equalTo("username", req.body.username);
        queryOne.first({
            success: function (user) {
                var query = new Parse.Query("ExtracurricularStructure");
                query.ascending("titleString");
                if (user.get("userType") === "Administration" || user.get("userType") === "Developer") {
                    //
                } else {
                    query.containedIn("extracurricularID", Parse.User.current().get("ownedEC")); // TODO
                };
                query.find({
                    success: function (structures) {
                        res.send({ res: structures });
                    },
                    error: function (error) {
                        res.send({ res: "Unable to load requested resource." });
                    }
                });
            },
            error: function (error) {
                res.send({ res: "Unable to load requested resource." });
            }
        });
    }
    else if (path == "group" && action == "manage" && request == "load") {
        var query = new Parse.Query("ExtracurricularStructure");
        query.ascending("titleString");
        if (Parse.User.current() && (Parse.User.current().get("userType") === "Developer" || Parse.User.current().get("userType") === "Administration")) {
            //
        } else {
            var array = Parse.User.current().get("ownedEC");
            query.containedIn("extracurricularID", array);
        };
        query.find({
            success: function (structures) {
                res.send({res: structures});
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "group" && action == "manage" && request == "edit") {
        var query = new Parse.Query("ExtracurricularStructure");
        query.equalTo("extracurricularID", parseInt(req.body.ID));
        query.first({
            success: function (structure) {
                structure.set("titleString", req.body.title);
                structure.set("descriptionString", req.body.content);
                structure.save(null, {
                    success: function (object) {
                        res.send({res: "SUCCESS"});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "group" && action == "manage" && request == "delete") {
        var query = new Parse.Query("ExtracurricularStructure");
        query.equalTo("extracurricularID", parseInt(req.body.ID));
        query.first({
            success: function (structure) {
                structure.destroy({
                    success: function (object) {
                        res.send({res: "SUCCESS"});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "poll" && action == "manage" && request == "load") {
        var query = new Parse.Query("PollStructure");
        query.descending("createdAt");
        var structures = new Array();
        query.find({
            success: function (structures) {
                res.send({ res: structures });
            }, error: function (error) {
                res.send({ res: error });
            }
        });
    }
    else if (path == "poll" && action == "manage" && request == "delete") {
        var query = new Parse.Query("PollStructure");
        query.equalTo("pollID", parseInt(req.body.ID));
        query.first({
            success: function (structure) {
                structure.destroy({
                    success: function (object) {
                        res.send({res: "SUCCESS"});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "scholarship" && action == "manage" && request == "load") {
        var query = new Parse.Query("ScholarshipStructure");
        query.descending("createdAt");
        var structures = new Array();
        query.find({
            success: function (structures) {
                res.send({ res: structures });
            }, error: function (error) {
                res.send({ res: error });
            }
        });
    }
    else if (path == "scholarship" && action == "manage" && request == "delete") {
        var query = new Parse.Query("ScholarshipStructure");
        query.equalTo("ID", parseInt(req.body.ID));
        query.first({
            success: function (structure) {
                structure.destroy({
                    success: function (object) {
                        res.send({res: "SUCCESS"});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "news" && action == "manage" && request == "load") {
        var query = new Parse.Query("NewsArticleStructure");
        query.descending("createdAt");
        query.equalTo("isApproved", 0);
        var requests = new Array();
        var current = new Array();
        query.find({
            success: function (structures) {
                requests = structures;
                var queryTwo = new Parse.Query("NewsArticleStructure");
                queryTwo.descending("createdAt");
                queryTwo.equalTo("isApproved", 1);
                queryTwo.find({
                    success: function (two) {
                        current = two;
                        res.send({requests: requests, current: current});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "news" && action == "manage" && request == "approve") {
        var query = new Parse.Query("NewsArticleStructure");
        query.equalTo("articleID", parseInt(req.body.ID));
        query.first({
            success: function(object) {
                object.set("isApproved", 1);
                object.save(null, {
                    success: function(done) {
                        res.send({res: "SUCCESS"});
                    },
                    error: function (error) {
                        res.send({res: error});
                    }
                });
            },
            error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "news" && action == "manage" && request == "delete") {
        var query = new Parse.Query("NewsArticleStructure");
        query.equalTo("articleID", parseInt(req.body.ID));
        query.first({
            success: function (structure) {
                structure.destroy({
                    success: function (object) {
                        res.send({res: "SUCCESS"});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "news" && action == "manage" && request == "deny") {
        var email = req.body.email;
        var name = req.body.name;
        var message = req.body.message;
        var title = req.body.title;
        var admin = req.body.admin;
        var adminMail = req.body.adminMail;
        var adminMailString = admin + "<" + adminMail + ">";
        var text = name + ",\n\nUnfortunately, your recent Wildcat News Story has been denied by a member of administration. Please see below for details.\n\nArticle Title - " + title + "\nDenial Message - " + message + "\nAdministrative User - " + admin + "\n\nIf you would like, you can recreate the article and resubmit for approval. Thank you for your understanding.\n\nBest,\n\nWildcatConnect App Team";
        // TODO - create configurable here ???
        utils.sendEmail(email, "WildcatConnect <team@wildcatconnect.org>", null, null, "Wildcat News Story Denial", text, false, res);
        utils.sendEmail(adminMailString, "WildcatConnect <team@wildcatconnect.org>", null, null, "Wildcat News Story Denial", text, false, res);
        var query = new Parse.Query("NewsArticleStructure");
        query.equalTo("articleID", parseInt(req.body.ID));
        query.first({
            success: function (structure) {
                structure.destroy({
                    success: function (object) {
                        res.send({res: "SUCCESS"});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "event" && action == "manage" && request == "load") {
        var query = new Parse.Query("EventStructure");
        query.descending("createdAt");
        query.equalTo("isApproved", 0);
        var requests = new Array();
        var current = new Array();
        query.find({
            success: function (structures) {
                requests = structures;
                var queryTwo = new Parse.Query("EventStructure");
                queryTwo.descending("createdAt");
                queryTwo.equalTo("isApproved", 1);
                queryTwo.find({
                    success: function (two) {
                        current = two;
                        res.send({requests: requests, current: current});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "event" && action == "manage" && request == "approve") {
        var query = new Parse.Query("EventStructure");
        query.equalTo("ID", parseInt(req.body.ID));
        query.first({
            success: function(object) {
                object.set("isApproved", 1);
                object.save(null, {
                    success: function(done) {
                        res.send({res: "SUCCESS"});
                    },
                    error: function (error) {
                        res.send({res: error});
                    }
                });
            },
            error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "event" && action == "manage" && request == "delete") {
        var query = new Parse.Query("EventStructure");
        query.equalTo("ID", parseInt(req.body.ID));
        query.first({
            success: function (structure) {
                structure.destroy({
                    success: function (object) {
                        res.send({res: "SUCCESS"});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "event" && action == "manage" && request == "deny") {
        var email = req.body.email;
        var name = req.body.name;
        var message = req.body.message;
        var title = req.body.title;
        var admin = req.body.admin;
        var adminMail = req.body.adminMail;
        var adminMailString = admin + "<" + adminMail + ">";
        var text = name + ",\n\nUnfortunately, your recent event has been denied by a member of administration. Please see below for details.\n\nEvent Title - " + title + "\nDenial Message - " + message + "\nAdministrative User - " + admin + "\n\nIf you would like, you can recreate the event and resubmit for approval. Thank you for your understanding.\n\nBest,\n\nWildcatConnect App Team";
        utils.sendEmail(email, "WildcatConnect <team@wildcatconnect.org>", null, null, "Event Denial", text, false, res);
        utils.sendEmail(adminMailString, "WildcatConnect <team@wildcatconnect.org>", null, null, "Event Denial", text, false, res);
        var query = new Parse.Query("EventStructure");
        query.equalTo("ID", parseInt(req.body.ID));
        query.first({
            success: function (structure) {
                structure.destroy({
                    success: function (object) {
                        res.send({res: "SUCCESS"});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "community" && action == "manage" && request == "load") {
        var query = new Parse.Query("CommunityServiceStructure");
        query.descending("createdAt");
        query.equalTo("isApproved", 0);
        var requests = new Array();
        var current = new Array();
        query.find({
            success: function (structures) {
                requests = structures;
                var queryTwo = new Parse.Query("CommunityServiceStructure");
                queryTwo.descending("createdAt");
                queryTwo.equalTo("isApproved", 1);
                queryTwo.find({
                    success: function (two) {
                        current = two;
                        res.send({requests: requests, current: current});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "community" && action == "manage" && request == "approve") {
        var query = new Parse.Query("CommunityServiceStructure");
        query.equalTo("communityServiceID", parseInt(req.body.ID));
        query.first({
            success: function(object) {
                object.set("isApproved", 1);
                object.save(null, {
                    success: function(done) {
                        res.send({res: "SUCCESS"});
                    },
                    error: function (error) {
                        res.send({res: error});
                    }
                });
            },
            error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "community" && action == "manage" && request == "delete") {
        var query = new Parse.Query("CommunityServiceStructure");
        query.equalTo("communityServiceID", parseInt(req.body.ID));
        query.first({
            success: function (structure) {
                structure.destroy({
                    success: function (object) {
                        res.send({res: "SUCCESS"});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "community" && action == "manage" && request == "deny") {
        var email = req.body.email;
        var name = req.body.name;
        var message = req.body.message;
        var title = req.body.title;
        var admin = req.body.admin;
        var adminMail = req.body.adminMail;
        var adminMailString = admin + "<" + adminMail + ">";
        var text = name + ",\n\nUnfortunately, your recent community service opportunity has been denied by a member of administration. Please see below for details.\n\nOpportunity Title - " + title + "\nDenial Message - " + message + "\nAdministrative User - " + admin + "\n\nIf you would like, you can recreate the opportunity and resubmit for approval. Thank you for your understanding.\n\nBest,\n\nWildcatConnect App Team";
        utils.sendEmail(email, "WildcatConnect <team@wildcatconnect.org>", null, null, "Community Service Denial", text, false, res);
        utils.sendEmail(adminMailString, "WildcatConnect <team@wildcatconnect.org>", null, null, "Community Service Denial", text, false, res);
        var query = new Parse.Query("CommunityServiceStructure");
        query.equalTo("communityServiceID", parseInt(req.body.ID));
        query.first({
            success: function (structure) {
                structure.destroy({
                    success: function (object) {
                        res.send({res: "SUCCESS"});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "alert" && action == "manage" && request == "load") {
        var query = new Parse.Query("AlertStructure");
        query.descending("createdAt");
        query.equalTo("isReady", 0);
        var requests = new Array();
        var current = new Array();
        query.find({
            success: function (structures) {
                requests = structures;
                var queryTwo = new Parse.Query("AlertStructure");
                queryTwo.descending("createdAt");
                queryTwo.equalTo("isReady", 1);
                queryTwo.find({
                    success: function (two) {
                        current = two;
                        res.send({requests: requests, current: current});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "alert" && action == "manage" && request == "delete") {
        var query = new Parse.Query("AlertStructure");
        query.equalTo("alertID", parseInt(req.body.ID));
        query.first({
            success: function (structure) {
                structure.destroy({
                    success: function (object) {
                        res.send({res: "SUCCESS"});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "alert" && action == "manage" && request == "edit") {
        var query = new Parse.Query("AlertStructure");
        query.equalTo("alertID", parseInt(req.body.ID));
        query.first({
            success: function (object) {
                var model = utils.initializeHomeUserModel(Parse.User.current());
                exports.prepareDashboard(model, path, action, request);
                var custom = new Models.AlertStructure();
                custom.title = object.get("titleString");
                custom.dateString = object.get("dateString");
                custom.content = object.get("contentString");
                custom.theTime = object.get("alertTime").toString();
                model.customModel = custom;
                res.render("../partials/dash/alert-new", { model: model, session: null});
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "user" && action == "manage" && request == "load") {
        var query = new Parse.Query("UserRegisterStructure");
        query.descending("createdAt");
        var requests = new Array();
        var current = new Array();
        query.find({
            success: function (structures) {
                requests = structures;
                var queryTwo = new Parse.Query("User");
                queryTwo.ascending("lastName");
                queryTwo.find({
                    success: function (two) {
                        current = two;
                        res.send({requests: requests, current: current});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    } else if (path == "user" && action == "manage" && request == "approve") {
        Parse.Cloud.run("registerUser", { useMasterKey: true, username: req.body.username }, {
            success: function(final) {
                res.send({ res: "SUCCESS" });
            }, error: function(error) {
                res.send({ res: error });
            }
        });
    } else if (path == "user" && action == "manage" && request == "delete") {
        Parse.Cloud.run("deleteUser", { useMasterKey: true, username: req.body.username }, {
            success: function(final) {
                res.send({ res: "SUCCESS" });
            }, error: function(error) {
                res.send({ res: error });
            }
        });
    } else if (path == "user" && action == "manage" && request == "deny") {
        var query = new Parse.Query("UserRegisterStructure");
        query.equalTo("username", req.body.username);
        query.first({
            success: function (structure) {
                structure.destroy({
                    success: function (object) {
                        res.send({res: "SUCCESS"});
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    } else if (path == "user" && action == "manage" && request == "update") {
        Parse.Cloud.run("updateUser", { useMasterKey: true, username: req.body.username, type: req.body.type }, {
            success: function(final) {
                res.send({ res: "SUCCESS" });
            }, error: function(error) {
                res.send({ res: error });
            }
        });
    }
};

exports.validateData = function(path, action, subaction, data) {
	var model = null;
	switch(path) {
		case "news":
			switch (action) {
				case "new":
					model = new Models.NewsArticleStructure();
					return model.validateData(data);
			}
		case "community":
			switch (action) {
				case "new":
					model = new Models.CommunityServiceStructure();
					return model.validateData(data);
			}
		case "event":
			switch (action) {
				case "new":
					model = new Models.EventStructure();
					return model.validateData(data);
			}
		case "group":
			switch (action){
				case "post":
					model = new Models.ExtracurricularUpdateStructure();
					return model.validateData(data);
                case "manage":
                    if (subaction == "create") {
                        model = new Models.ExtracurricularStructure();
                        return model.validateData(data);
                    }
			}
        case "poll":
            switch (action) {
                case "new":
                    model = new Models.PollStructure();
                    return model.validateData(data);
            }
        case "scholarship":
            switch (action) {
                case "new":
                    model = new Models.ScholarshipStructure();
                    return model.validateData(data);
            }
        case "alert":
            switch (action) {
                case "new":
                    model = new Models.AlertStructure();
                    return model.validateData(data);
            }
		case "settings":
			model = new Models.Settings();
			model.renderModel(action);
			return model.validateData(data);
	}
};

exports.prepareDashboard = function(model, path, action, subaction) {
	model.renderModel(path, action, subaction);
};