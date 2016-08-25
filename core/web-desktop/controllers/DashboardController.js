var Promise = require('promise');
var ApplicationMessage = require('../models/message');
var Classes = require('../utils/classes');
var utils = require('../utils/utils');
var moment = require('moment');
var Models = require('../models/models');
var AccountController = require("./AccountController");
var ejs = require("ejs");
var pathModule = require("path");
var fs = require("fs");

exports.authenticate = function(req, res) {
	if (req.session.user) {
	    exports.checkActive().then(function (response) {
	        if (response.auth || req.session.user["userType"] == "Developer") {
                var model = utils.initializeHomeUserModel(req.session.user);
                var path = req.body.path != null ? req.body.path : "home";
                var action = req.body.action;
                exports.prepareDashboard(model, path, action);
                var session = Object.assign({ }, req.session);
                delete req.session.theErrors;
                res.render("main", { model: model, session: session });
            } else if (response.auth == false && response.error == null) {
                // App inactive!!!
                // What do we do with users???
                req.session.user = null;
                try {
                    Parse.User.logOut();
                } catch (e) {
                    // Move on
                }
                var model = utils.initializeHomeUserModel(null);
                var path = "home";
                exports.prepareDashboard(model, path, null);
                var session = Object.assign({ }, req.session);
                delete req.session.theErrors;
                res.render("inactive", { model: model, message: response.message, session: session });
            } else {
                var rawError = new Error();
                var error = response.error;
                var x = utils.processError(error, rawError, null);
                utils.log('error', x.message, { "stack" : x.stack , "objects" : x.objects });
            }
        });
	} else {
		res.redirect('/app/login');
	}
};

exports.processPost = function(req, res, path, action, subaction, data) {
	var obj = exports.validateData(req, path, action, subaction, data, req.session.user);
	if (obj.result == false) {
		var model = utils.initializeHomeUserModel(req.session.user);
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
		var model = utils.initializeHomeUserModel(req.session.user);
		model.renderModel("home", null);
		model.customModel = obj.model;
		return exports.saveModel(model, req, res, obj.message, path, action, subaction);
	}
};

exports.saveModel = function(model, req, res, message, path, action, subaction) {
    if (utils.needCustomSaveOperation(model)) {
        utils.customSaveOperation(model, req).then(function (response) {
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
	if (error == null || Object.keys(error).length == 0) {
		var model = utils.initializeHomeUserModel(req.session.user);
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
		var model = utils.initializeHomeUserModel(req.session.user);
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

exports.home = function(req, res) {
    var model = utils.initializeHomeUserModel(req.session.user);
    model.page.title = config.page.applicationName;
    return res.render("home", { model: model });
};

exports.homePost = function (req, res) {
    var action = req.params.action;
    if (action == "statistics") {
        Parse.Cloud.run("countInstallations", null, {
            success: function (install) {
                var queryTwo = new Parse.Query("User");
                queryTwo.count().then(function (user) {
                    var queryThree = new Parse.Query("ContentStructure"); // TO DO - Make archive to look for old ones (:
                    queryThree.first().then(function (obj) {
                        var count = obj.get("value");
                        res.send({install: install, user: user, content: count});
                    })
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
};

exports.mainPost = function(req, res) {
    var action = req.params.action;
    if (action == "load") {
        var query = new Parse.Query("SpecialKeyStructure");
        query.equalTo("key", "webMessage");
        query.first({
            success: function (object) {
                var value = object.get("value");
                res.send({message: value});
            },
            error: function(error) {
                res.send({res: error});
            }
        });
    }
};

exports.route = function(req, res, next) {
    if (req.session.user) {
        if (req.method == 'GET') {
            exports.checkActive().then(function (response) {
                if (response.auth || req.session.user["userType"] == "Developer") {
                    var path = req.params.path;
                    var action = req.params.action;
                    var subaction = req.params.subaction;
                    var model = utils.initializeHomeUserModel(req.session.user);
                    exports.prepareDashboard(model, path, action, subaction);
                    var allow = utils.verifyPage(model);
                    if (allow) {
                        var session = Object.assign({ }, req.session);
                        delete req.session.theErrors;
                        if (model.doRender)
                            return res.render("main", { model: model, session: session });
                        else {
                            next();
                        }
                    } else {
                        var myError = new ApplicationMessage();
                        myError.message = "You do not have sufficient privileges to access this page.";
                        myError.isError = true;
                        if (! req.session.theErrors)
                            req.session.theErrors = new Array();
                        req.session.theErrors.push(myError);
                        res.redirect("/app/dashboard");
                    }
                } else if (response.auth == false && response.error == null) {
                    // App inactive!!!
                    // What do we do with users???
                    req.session.user = null;
                    try {
                        Parse.User.logOut();
                    } catch (e) {
                        // Move on
                    }
                    var model = utils.initializeHomeUserModel(null);
                    var path = "home";
                    exports.prepareDashboard(model, path, null);
                    var session = Object.assign({ }, req.session);
                    delete req.session.theErrors;
                    res.render("inactive", { model: model, message: response.message, session: session });
                } else {
                    var rawError = new Error();
                    var error = response.error;
                    var x = utils.processError(error, rawError, null);
                    utils.log('error', x.message, { "stack" : x.stack , "objects" : x.objects });
                }
            });
        } else if (req.method == 'POST') {
            var path = req.params.path;
            var action = req.params.action;
            var subaction = req.params.subaction;
            return exports.handlePost(req, res, path, action, subaction);
        }
    } else {
        res.redirect('/app/login');
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
                    query.containedIn("extracurricularID", req.session.user["ownedEC"]); // TODO
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
        if (req.session.user && (req.session.user["userType"] === "Developer" || req.session.user["userType"] === "Administration")) {
            //
        } else {
            var array = req.session.user["ownedEC"];
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
        var filePath = pathModule.join(__dirname, "../mail", "denial.ejs");
        var templateContent = fs.readFileSync(filePath, 'utf8');
        var model = new Models.Denial();
        model.renderModel(req.body, "news");
        var html = ejs.render(templateContent, { model: model });
        var email = req.body.email;
        var adminMailString = req.body.admin + "<" + req.body.adminMail + ">";
        // TODO - Configure these values.
        var subject = config.page.newsStructure + " Denial";
        utils.sendEmail(email, config.page.teamMailString, null, null, subject, html, true, res);
        utils.sendEmail(adminMailString, config.page.teamMailString, null, null, subject, html, true, res);
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
        var filePath = pathModule.join(__dirname, "../mail", "denial.ejs");
        var templateContent = fs.readFileSync(filePath, 'utf8');
        var model = new Models.Denial();
        model.renderModel(req.body, "event");
        var html = ejs.render(templateContent, { model: model });
        var email = req.body.email;
        var adminMailString = req.body.admin + "<" + req.body.adminMail + ">";
        // TODO - Configure these values.
        utils.sendEmail(email, config.page.teamMailString, null, null, "Event Denial", html, true, res);
        utils.sendEmail(adminMailString, config.page.teamMailString, null, null, "Event Denial", html, true, res);
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
        var filePath = pathModule.join(__dirname, "../mail", "denial.ejs");
        var templateContent = fs.readFileSync(filePath, 'utf8');
        var model = new Models.Denial();
        model.renderModel(req.body, "cs");
        var html = ejs.render(templateContent, { model: model });
        var email = req.body.email;
        var adminMailString = req.body.admin + "<" + req.body.adminMail + ">";
        // TODO - Configure these values.
        utils.sendEmail(email, config.page.teamMailString, null, null, "Community Service Denial", html, true, res);
        utils.sendEmail(adminMailString, config.page.teamMailString, null, null, "Community Service Denial", html, true, res);
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
                var model = utils.initializeHomeUserModel(req.session.user);
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
    }
    else if (path == "user" && action == "manage" && request == "approve") {
        Parse.Cloud.run("registerUser", { useMasterKey: true, username: req.body.username }, {
            success: function(final) {
                res.send({ res: "SUCCESS" });
            }, error: function(error) {
                res.send({ res: error });
            }
        });
    }
    else if (path == "user" && action == "manage" && request == "delete") {
        Parse.Cloud.run("deleteUser", { username: req.body.username }, {
            success: function(final) {
                res.send({ res: "SUCCESS" });
            }, error: function(error) {
                res.send({ res: error });
            }
        });
    }
    else if (path == "user" && action == "manage" && request == "deny") {
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
    }
    else if (path == "user" && action == "manage" && request == "update") {
        Parse.Cloud.run("updateUser", { username: req.body.username, type: req.body.type }, {
            success: function(final) {
                res.send({ res: "SUCCESS" });
            }, error: function(error) {
                res.send({ res: error });
            }
        });
    }
    else if (path == "schedule" && action == "manage" && request == "load") {
        var dictionary = { };
        var firstQuery = new Parse.Query("ScheduleType");
        firstQuery.ascending("typeID");
        firstQuery.find({
            success: function (objects) {
                for (var j = 0; j < objects.length; j++) {
                    var key = objects[j].get("typeID");
                    var value = objects[j].get("fullScheduleString");
                    dictionary[key] = value;
                };
                var query = new Parse.Query("SchoolDayStructure");
                query.equalTo("isActive", 1);
                query.ascending("schoolDayID");
                var structures = new Array();
                query.find({
                    success: function (theStructures) {

                        var queryTwo = new Parse.Query("SchoolDayStructure");
                        queryTwo.equalTo("isActive", 0);
                        queryTwo.descending("schoolDayID");

                        queryTwo.first({
                            success: function (day) {

                                structures.push(day);

                                for (var i = 0; i < theStructures.length; i++) {
                                    structures.push(theStructures[i]);
                                }

                                var queryLast = new Parse.Query("SpecialKeyStructure");
                                queryLast.equalTo("key", "scheduleMode");
                                queryLast.first({
                                    success: function(object) {
                                        var theString = object.get("value");
                                        var obj = {
                                            structures: structures,
                                            dictionary: dictionary,
                                            mode: theString.toString()
                                        };
                                        res.send(obj);
                                    },
                                    error: function(error) {
                                        res.send({res: error});
                                    }
                                });
                            }, error: function (error) {
                                res.send({res: error});
                            }
                        });
                    }, error: function (error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "schedule" && action == "manage" && request == "edit") {
        var query = new Parse.Query("SchoolDayStructure");
        query.equalTo("schoolDayID", parseInt(req.body.ID));
        query.first({
            success: function(object) {
                object.set("customString",  req.body.title);
                object.set("customSchedule",  req.body.schedule);
                object.set("scheduleType", "*");
                object.save(null, {
                    success: function() {
                        res.send({res: "SUCCESS"});
                    },
                    error: function(error) {
                        res.send({ res: error });
                    }
                });
            },
            error: function(error) {
                res.send({ res: error });
            }
        });
    }
    else if (path == "schedule" && action == "manage" && request == "mode") {
        var query = new Parse.Query("SpecialKeyStructure");
        query.equalTo("key", "scheduleMode");
        query.first({
            success: function(object) {
                object.set("value", req.body.mode);
                object.save({
                    success: function() {
                        res.send({res: "SUCCESS"});
                    },
                    error: function(error) {
                        res.send({ res: error });
                    }
                });
            },
            error: function(error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "schedule" && action == "manage" && request == "snow") {
        var array = [];
        var ID = parseInt(req.body.ID);
        var hasChanged = false;
        var query = new Parse.Query("SchoolDayStructure");
        query.descending("schoolDayID");
        query.find( {
            success: function (results) {
                for (var i = 0; i < results.length; i++) {
                    if (results[i].get("schoolDayID") > ID && i != results.length - 1) {
                        var nextScheduleType = results[i + 1].get("scheduleType");
                        if (nextScheduleType === "*") {
                            //Set the custom schedule as well!
                            results[i].set("customSchedule", results[i + 1].get("customSchedule"));
                            results[i].set("customString", results[i + 1].get("customString"));
                        };
                        results[i].set("scheduleType", nextScheduleType);
                        array.push(results[i]);
                    } else if (results[i].get("schoolDayID") === ID) {
                        results[i].set("isActive", 0);
                        results[i].set("isSnow", 1);
                        results[i].save(null, {
                            success: function(myObject) {
                                //No response yet...
                            },
                            error: function(myObject, error) {
                                res.send({ res: error });
                            }
                        });
                    };
                };
                Parse.Object.saveAll(array, {
                    success: function() {
                        res.send({res: "SUCCESS"});
                    },
                    error: function(objects, error) {
                        res.send({ res: error });
                    }
                });
            },
            error: function (error) {
                res.send({ res: error });
            }
        });
    }
    else if (path == "schedule" && action == "manage" && request == "update") {
        var mode = req.body.mode;
        var ID = parseInt(req.body.ID);
        var query = new Parse.Query("SchoolDayStructure");
        query.equalTo("schoolDayID", ID);
        query.first({
            success: function (object) {
                object.set("scheduleType", mode);
                object.set("customSchedule", "None.");
                object.set("customString", "");
                object.save(null, {
                    success: function (object) {
                        res.send({res: "SUCCESS"});
                    }, error: function (error) {
                        res.send({res:error});
                    }
                });
            }, error: function (error) {
                res.send({res:error});
            }
        });
    } else if (path == "food" && action == "manage" && request == "load") {
        var query = new Parse.Query("SchoolDayStructure");
        query.equalTo("isActive", 1);
        query.ascending("schoolDayID");
        query.find({
            success: function (structures) {
                res.send({structures:structures});
            }, error: function (error) {
                res.send({res:error});
            }
        });
    }
    else if (path == "food" && action == "manage" && request == "save") {
        var breakfast = req.body.breakfast;
        var lunch = req.body.lunch;
        var array = new Array();
        var query = new Parse.Query("SchoolDayStructure");
        query.equalTo("isActive", 1);
        query.ascending("schoolDayID");
        query.find({
            success: function (structures) {
                for (var i = 0; i < structures.length; i++) {
                    structures[i].set("breakfastString", breakfast[i]);
                    structures[i].set("lunchString", lunch[i]);
                    array.push(structures[i]);
                }
                ;
                Parse.Object.saveAll(array, {
                    success: function () {
                        res.send({res: "SUCCESS"});
                    }, error: function (objects, error) {
                        res.send({res: error});
                    }
                });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "dev" && action == "manage" && request == "load") {
        Parse.Cloud.run("countInstallations", null, {
            success: function(count) {
                var query = new Parse.Query("SpecialKeyStructure");
                query.equalTo("key", "appActive");
                query.first({
                    success: function(active) {
                        active = active.get("value");
                        var query = new Parse.Query("SpecialKeyStructure");
                        query.find({
                            success: function(objects) {
                                var message = utils.linqForKeyValuePair(objects, "key", "appMessage", true).get("value");
                                var webMessage = utils.linqForKeyValuePair(objects, "key", "webMessage", true).get("value");
                                res.send({ count: count, active: active, message: message, webMessage: webMessage });
                            },
                            error: function(error) {
                                res.send({res: error});
                            }
                        });
                    },
                    error: function(error) {
                        res.send({res: error});
                    }
                });
            },
            error: function(error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "dev" && action == "manage" && request == "active") {
        var status = req.body.active;
        if (parseInt(status) == 0) {
            var query = new Parse.Query("SpecialKeyStructure");
            query.equalTo("key", "appActive");
            query.first({
                success: function(active) {
                    var rawPass = active.get("password");
                    var password = utils.decrypt(rawPass);
                    if (req.body.password == password) {
                        active.set("value", req.body.active.toString());
                        var message = req.body.message;
                        active.set("message", message);
                        active.save(null, {
                            success: function(final) {
                                res.send({res: "SUCCESS"});
                            }, error: function(object, error) {
                                res.send({res: error});
                            }
                        });
                    } else {
                        res.send({res: "Invalid developer password for this action."});
                    }
                },
                error: function(error) {
                    res.send({res: error});
                }
            });
        } else {
            var query = new Parse.Query("SpecialKeyStructure");
            query.equalTo("key", "appActive");
            query.first({
                success: function(active) {
                    active.set("value", req.body.active.toString());
                    active.set("message", "None.");
                    active.save(null, {
                        success: function(final) {
                            res.send({res: "SUCCESS"});
                        }, error: function(object, error) {
                            res.send({res: error});
                        }
                    });
                },
                error: function(error) {
                    res.send({res: error});
                }
            });
        }
    }
    else if (path == "dev" && action == "manage" && request == "message") {
        var message = req.body.message;
        var type = req.body.type;
        var query = new Parse.Query("SpecialKeyStructure");
        if (type == "app")
            query.equalTo("key", "appMessage");
        else if (type == "web")
            query.equalTo("key", "webMessage");
        query.first({
            success: function(active) {
                active.set("value", message);
                active.save(null, {
                    success: function(final) {
                        res.send({res: "SUCCESS"});
                    }, error: function(object, error) {
                        res.send({res: error});
                    }
                });
            },
            error: function(error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "dev" && action == "links" && request == "load") {
        var query = new Parse.Query("UsefulLinkArray");
        query.ascending("index");
        query.find({
            success: function(structures) {
                res.send({ structures: structures });
            }, error: function (error) {
                res.send({res: error});
            }
        });
    }
    else if (path == "daily" && action == "manage" && request == "load") {
        var query = new Parse.Query("SchoolDayStructure");
        query.equalTo("isActive", 1);
        query.ascending("schoolDayID");
        query.limit(3);
        var schoolDays = new Array();
        var news = new Array();
        var scholarships = new Array();
        var community = new Array();
        var events = new Array();
        query.find().then(function(list) {
            schoolDays = list;
            var queryTwo = new Parse.Query("NewsArticleStructure");
            queryTwo.descending("createdAt");
            queryTwo.equalTo("isApproved", 1);
            queryTwo.limit(5);
            return queryTwo.find();
        }).then(function(list) {
            news = list;
            /*for (var i = 0; i < list.length; i++) {
                textArray[list[i].get("articleID")] = list[i].get("contentURLString");
            };*/
            var queryThree = new Parse.Query("ScholarshipStructure");
            queryThree.ascending("dueDate");
            return queryThree.find();
        }).then(function(list) {
            scholarships = list;
            var queryFour = new Parse.Query("CommunityServiceStructure");
            queryFour.ascending("startDate");
            queryFour.equalTo("isApproved", 1);
            return queryFour.find();
        }).then(function(list) {
            community = list;
            var queryFive = new Parse.Query("EventStructure");
            queryFive.ascending("eventDate");
            queryFive.equalTo("isApproved", 1);
            queryFive.limit(7);
            return queryFive.find();
        }).then(function(list) {
            events = list;
            res.send({ schoolDays: schoolDays, news: news, scholarships: scholarships, community: community, events: events });
        });
    }
    else if (path == "daily" && action == "manage" && request == "type") {
        var code = req.body.code;
        var query = new Parse.Query("ScheduleType");
        query.equalTo("typeID", code);
        query.first({
            success: function(object) {
                res.send({fullScheduleString: object.get('fullScheduleString'), scheduleString: object.get("scheduleString")});
            }, error: function(error) {
                res.send({res:error});
            }
        });
    }
};

exports.validateData = function(req, path, action, subaction, data, user) {
	var model = null;
	switch(path) {
		case "news":
			switch (action) {
				case "new":
					model = new Models.NewsArticleStructure();
					return model.validateData(data, user);
			}
		case "community":
			switch (action) {
				case "new":
					model = new Models.CommunityServiceStructure();
					return model.validateData(data, user);
			}
		case "event":
			switch (action) {
				case "new":
					model = new Models.EventStructure();
					return model.validateData(data, user);
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
			return model.validateData(data, req.session.user["email"]);
	}
};

exports.prepareDashboard = function(model, path, action, subaction) {
	model.renderModel(path, action, subaction);
};

exports.checkActive = function() {
    return new Promise(function(fulfill, reject) {
        try {
            var query = new Parse.Query("SpecialKeyStructure");
            query.equalTo("key", "appActive");
            query.first({
                success: function (object) {
                    var result = parseInt(object.get("value")) == 1;
                    var message = object.get("message");
                    fulfill({ auth: result, message: message });
                }, error: function (error) {
                    fulfill({ auth: false , error: error });
                }
            });
        } catch (e) {
            fulfill({ auth: false , error: e });
        }
    });
}