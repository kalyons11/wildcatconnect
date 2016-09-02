var utils = require('../utils/utils');
var moment = require('moment');

exports.handleJob = function(req, res) {
   if (req.body.secret == utils.decrypt(global.config.jobSecret)) {
        var name = req.params.name;
        switch (name) {
            case "test":
                res.send("YES!!!");
            case "newsDelete":
                return exports.newsDelete(req, res);
            case "eventDelete":
                return exports.eventDelete(req, res);
            case "commDelete":
                return exports.commDelete(req, res);
            case "pollDelete":
                return exports.pollDelete(req, res);
            case "alertDelete":
                return exports.alertDelete(req, res);
            case "scholarshipDelete":
                return exports.scholarshipDelete(req, res);
            case "alertPush":
                return exports.alertPush(req, res);
            case "dayGenerate":
                return exports.dayGenerate(req, res);
            case "dayDelete":
                return exports.dayDelete(req, res);
            case "ECUdelete":
                return exports.ECUdelete(req, res);
        }
    } else {
        utils.log("error", "Forbidden access detected from IP address: " + req.connection.remoteAddress, null);
        res.status(401).send("FORBIDDEN ACCESS");
    }
};

exports.newsDelete = function(req, res) {
    var query = new Parse.Query("NewsArticleStructure");
    query.ascending("articleID");
    query.find({
        success: function(structures) {
            for (var i = 0; i < structures.length; i++) {
                var currentStructure = structures[i];
                var thisDate = currentStructure.get("createdAt");
                var now = new Date();
                var one_day=1000*60*60*24;
                var date1_ms = thisDate.getTime();
                var date2_ms = now.getTime();
                var difference_ms = date2_ms - date1_ms;
                difference_ms = Math.round(difference_ms/one_day);
                if (difference_ms >= 10) {
                    currentStructure.destroy({
                        success: function() {
                            console.log("Just deleted an object!!!");
                        },
                        error: function(error) {
                            var rawError = new Error();
                            var x = utils.processError(error, rawError, null);
                            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                            res.send(error.toString());
                        }
                    });
                };
                if (i == structures.length - 1) {
                    utils.log('info', 'News articles successfully deleted.', null);
                    res.send("SUCCESS");
                };
            }
            if (structures.length == 0) {
                utils.log('info', 'No news articles to delete.', null);
                res.send("No objects to delete!");
            };
        },
        error: function(error) {
            var rawError = new Error();
            var x = utils.processError(error, rawError, null);
            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
            res.send(error.toString());
        }
    });
};

exports.eventDelete = function(req, res) {
    var query = new Parse.Query("EventStructure");
    query.ascending("eventDate");
    query.find({
        success: function(structures) {
            for (var i = 0; i < structures.length; i++) {
                var currentStructure = structures[i];
                var thisDate = currentStructure.get("eventDate");
                var now = new Date();
                var date1_ms = thisDate.getTime();
                var date2_ms = now.getTime();
                var difference_ms = date2_ms - date1_ms;
                if (difference_ms >= 0) {
                    currentStructure.destroy({
                        success: function() {
                            console.log("Just deleted an object!!!");
                        },
                        error: function(error) {
                            var rawError = new Error();
                            var x = utils.processError(error, rawError, null);
                            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                            res.send(error.toString());
                        }
                    });
                };
                if (i == structures.length - 1) {
                    utils.log('info', 'Events successfully deleted.', null);
                    res.send("SUCCESS");
                };
            }
            if (structures.length == 0) {
                utils.log('info', 'No events.', null);
                res.send("No objects to delete!");
            };
        },
        error: function() {
            var rawError = new Error();
            var x = utils.processError(error, rawError, null);
            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
            res.send(error.toString());
        }
    });
};

exports.commDelete = function(req, res) {
    var query = new Parse.Query("CommunityServiceStructure");
    query.ascending("communityServiceID");
    query.find({
        success: function(structures) {
            for (var i = 0; i < structures.length; i++) {
                var currentStructure = structures[i];
                var thisDate = currentStructure.get("endDate");
                var now = new Date();
                var one_day=1000*60*60*24;
                var date1_ms = thisDate.getTime();
                var date2_ms = now.getTime();
                var difference_ms = date2_ms - date1_ms;
                difference_ms = Math.round(difference_ms/one_day);
                if (difference_ms >= 0) {
                    currentStructure.destroy({
                        success: function() {
                            console.log("Just deleted an object!!!");
                        },
                        error: function(error) {
                            var rawError = new Error();
                            var x = utils.processError(error, rawError, null);
                            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                            res.send(error.toString());
                        }
                    });
                };
                if (i == structures.length - 1) {
                    utils.log('info', 'Opportunities successfully deleted.', null);
                    res.send("SUCCESS");
                };
            }
            if (structures.length == 0) {
                utils.log('info', 'No opportunities to delete.', null);
                res.send("No objects to delete!");
            };
        },
        error: function(error) {
            var rawError = new Error();
            var x = utils.processError(error, rawError, null);
            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
            res.send(error.toString());
        }
    });
};

exports.pollDelete = function(req, res) {
    var query = new Parse.Query("PollStructure");
    query.ascending("pollID");
    query.find({
        success: function(structures) {
            for (var i = 0; i < structures.length; i++) {
                var currentStructure = structures[i];
                var thisDate = currentStructure.get("createdAt");
                var now = new Date();
                var one_day=1000*60*60*24;
                var date1_ms = thisDate.getTime();
                var date2_ms = now.getTime();
                var difference_ms = date2_ms - date1_ms;
                difference_ms = Math.round(difference_ms/one_day);
                if (difference_ms >= currentStructure.get("daysActive")) {
                    currentStructure.save({
                        "isActive" : 0
                    }, {
                        success: function() {
                            console.log("Just updated an object!!!");
                        },
                        error: function(error) {
                            var rawError = new Error();
                            var x = utils.processError(error, rawError, null);
                            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                            res.send(error.toString());
                        }
                    });
                };
                if (i == structures.length - 1) {
                    utils.log('info', 'Polls successfully deleted.', null);
                    res.send("SUCCESS");
                };
            }
            if (structures.length == 0) {
                utils.log('info', 'No polls to delete.', null);
                res.send("No objects to delete!");
            };
        },
        error: function(error) {
            var rawError = new Error();
            var x = utils.processError(error, rawError, null);
            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
            res.send(error.toString());
        }
    });
};

exports.alertDelete = function(req, res) {
    var query = new Parse.Query("AlertStructure");
    query.ascending("alertID");
    query.find({
        success: function(structures) {
            for (var i = 0; i < structures.length; i++) {
                var currentStructure = structures[i];
                var thisDate = currentStructure.createdAt;
                var now = new Date();
                var one_day=1000*60*60*24;
                var date1_ms = thisDate.getTime();
                var date2_ms = now.getTime();
                var difference_ms = date2_ms - date1_ms;
                difference_ms = Math.round(difference_ms/one_day);
                console.log(difference_ms);
                if (difference_ms > 21) {
                    currentStructure.destroy({
                        success: function() {
                            console.log("Just deleted an object!!!");
                        },
                        error: function(error) {
                            var rawError = new Error();
                            var x = utils.processError(error, rawError, null);
                            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                            res.send(error.toString());s
                        }
                    });
                };
                if (i == structures.length - 1) {
                    utils.log('info', 'Alerts successfully deleted.', null);
                    res.send("SUCCESS");
                };
            }
            if (structures.length == 0) {
                utils.log('info', 'No alerts to delete.', null);
                res.send("No objects to delete!");
            };
        },
        error: function(error) {
            var rawError = new Error();
            var x = utils.processError(error, rawError, null);
            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
            res.send(error.toString());
        }
    });
};

exports.scholarshipDelete = function (req, res) {
    var query = new Parse.Query("ScholarshipStructure");
    query.ascending("dueDate");
    var array = new Array();
    query.find().then(function(objects) {
        var now = new Date();
        for (var i = 0; i < objects.length; i++) {
            var currentStructure = objects[i];
            var thisDate = currentStructure.get("dueDate");
            var now = new Date();
            var one_day=1000*60*60*24;
            var date1_ms = thisDate.getTime();
            var date2_ms = now.getTime();
            var difference_ms = date2_ms - date1_ms;
            difference_ms = Math.round(difference_ms/one_day);
            if (difference_ms >= 2) {
                array.push(currentStructure);
            };
        };
        return Parse.Object.destroyAll(array);
    }).then(function(objectsGone){
        utils.log('info', 'Scholarships successfully deleted.', null);
        res.send("SUCCESS");
    }), function(error) {
        var rawError = new Error();
        var x = utils.processError(error, rawError, null);
        utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
        res.send(error.toString());
    };
};

exports.alertPush = function (req, res) {
    var query = new Parse.Query("AlertStructure");
    var existingString = null;
    var pushSent = false;
    query.ascending("alertID");
    query.equalTo("isReady", 0);
    query.find({
        success: function(structures) {
            for (var i = 0; i < structures.length; i++) {
                var currentStructure = structures[i];
                var thisDate = currentStructure.get("alertTime");
                var now = new Date();
                var date1_ms = thisDate.getTime();
                var date2_ms = now.getTime();
                var difference_ms = date2_ms - date1_ms;
                if (difference_ms >= 0 || (thisDate.getHours() === now.getHours() && thisDate.getMinutes() === now.getMinutes())) {
                    pushSent = true;
                    currentStructure.set("isReady", 1);
                    currentStructure.save(null, {
                        success: function (currentStructure) {
                            // Execute any logic that should take place after the object is saved.
                            //alert('New object created with objectId: ' + gameScore.id);
                            var query = new Parse.Query("SchoolDayStructure");
                            query.equalTo("isActive", 1);
                            query.ascending("schoolDayID");
                            query.first({
                                success: function(structure) {
                                    var messageString;
                                    if (existingString != null) {
                                        messageString = existingString;
                                    } else {
                                        messageString = structure.get("messageString");
                                    }
                                    if (messageString === "No alerts yet.") {
                                        messageString = currentStructure.get("titleString");
                                    } else {
                                        messageString = messageString + "\n\n" + currentStructure.get("titleString");
                                    };
                                    existingString = messageString;
                                    structure.set("messageString", messageString);
                                    structure.save(null, {
                                        success: function(structure) {
                                            // Execute any logic that should take place after the object is saved.
                                            //alert('New object created with objectId: ' + gameScore.id);
                                            //
                                            if (i == structures.length - 1) {
                                                if (pushSent === true) {
                                                    utils.log('info', 'Alert successfully pushed.', null);
                                                    res.send("SUCCESS");
                                                }
                                            };
                                        },
                                        error: function(error) {
                                            var rawError = new Error();
                                            var x = utils.processError(error, rawError, null);
                                            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                                            res.send(error.toString());
                                        }
                                    });
                                },
                                error: function(errorTwo) {
                                    response.error("Error.");
                                }
                            });
                        },
                        error: function(currentStructure, error) {
                            // Execute any logic that should take place if the save fails.
                            // error is a Parse.Error with an error code and message.
                            //alert('Failed to create new object, with error code: ' + error.message);
                            var rawError = new Error();
                            var x = utils.processError(error, rawError, null);
                            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                            res.send(error.toString());
                        }
                    });
                } else if (i == structures.length - 1) {
                    if (pushSent === false) {
                        utils.log('info', 'No alerts sent!', null);
                        res.send("SUCCESS");
                    }
                };
            }
            if (structures.length == 0) {
                utils.log('info', 'No alerts to be sent!', null);
                res.send("SUCCESS");
            };
        },
        error: function() {
            var rawError = new Error();
            var x = utils.processError(error, rawError, null);
            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
            res.send(error.toString());
        }
    });
};

exports.dayGenerate = function (req, res) {
    var query = new Parse.Query("SpecialKeyStructure");
    query.equalTo("key", "scheduleMode");
    query.first({
        success: function(object) {
            var date = new Date();
            if (object.get("value") === "NORMAL" && date.getDay() != 0 && date.getDay() != 1) {
                var query = new Parse.Query("SchoolDayStructure");
                query.descending("schoolDayID");
                query.first({
                    success: function(object) {
                        var ID = object.get("schoolDayID") + 1;
                        var oldDate = object.get("schoolDate");
                        var oldDateDate =  moment(oldDate, "MM-DD-YYYY");
                        var thatDay = oldDateDate.day();
                        if (thatDay === 5) {
                            var newDateDate = oldDateDate.add(3, 'days');
                            var newDate = newDateDate.format("MM-DD-YYYY");
                            var oldType = object.get("scheduleType");
                            var newType = "*";
                            if (oldType.indexOf("A") > -1) {
                                newType = "B1";
                            } else if (oldType.indexOf("B") > -1) {
                                newType = "C1";
                            } else if (oldType.indexOf("C") > -1) {
                                newType = "D1";
                            } else if (oldType.indexOf("D") > -1) {
                                newType = "E1";
                            } else if (oldType.indexOf("E") > -1) {
                                newType = "F1";
                            } else if (oldType.indexOf("F") > -1) {
                                newType = "G1";
                            } else if (oldType.indexOf("G") > -1) {
                                newType = "A1";
                            };
                            var SchoolDayStructure = Parse.Object.extend("SchoolDayStructure");
                            var newDay = new SchoolDayStructure();
                            newDay.save({
                                "hasImage": 0,
                                "imageString" : "None.",
                                "messageString" : "No alerts yet.",
                                "scheduleType" : newType,
                                "schoolDate" : newDate,
                                "imageUser" : "None.",
                                "customSchedule" : "None",
                                "imageUserFullString" : "None.",
                                "schoolDayID" : ID,
                                "isActive" : 1,
                                "customString" : "",
                                "breakfastString" : "No breakfast data.",
                                "lunchString" : "No lunch data.",
                                "isSnow" : 0
                            }, {
                                success: function(savedObject) {
                                    res.send("SUCCESS");
                                },
                                error: function(savedObject, error) {
                                    var rawError = new Error();
                                    var x = utils.processError(error, rawError, null);
                                    utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                                    res.send(error.toString());
                                }
                            });
                        } else {
                            var newDateDate = oldDateDate.add(1, 'days');
                            var newDate = newDateDate.format("MM-DD-YYYY");
                            var oldType = object.get("scheduleType");
                            var newType = "*";
                            if (oldType.indexOf("A") > -1) {
                                newType = "B";
                            } else if (oldType.indexOf("B") > -1) {
                                newType = "C";
                            } else if (oldType.indexOf("C") > -1) {
                                newType = "D";
                            } else if (oldType.indexOf("D") > -1) {
                                newType = "E";
                            } else if (oldType.indexOf("E") > -1) {
                                newType = "F";
                            } else if (oldType.indexOf("F") > -1) {
                                newType = "G";
                            } else if (oldType.indexOf("G") > -1) {
                                newType = "A";
                            };
                            var SchoolDayStructure = Parse.Object.extend("SchoolDayStructure");
                            var newDay = new SchoolDayStructure();
                            newDay.save({
                                "hasImage": 0,
                                "imageString" : "None.",
                                "messageString" : "No alerts yet.",
                                "scheduleType" : newType,
                                "schoolDate" : newDate,
                                "imageUser" : "None.",
                                "customSchedule" : "None",
                                "imageUserFullString" : "None.",
                                "schoolDayID" : ID,
                                "isActive" : 1,
                                "customString" : "",
                                "breakfastString" : "No breakfast data.",
                                "lunchString" : "No lunch data.",
                                "isSnow" : 0
                            }, {
                                success: function(savedObject) {
                                    res.send("SUCCESS");
                                },
                                error: function(savedObject, error) {
                                    var rawError = new Error();
                                    var x = utils.processError(error, rawError, null);
                                    utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                                    res.send(error.toString());
                                }
                            });
                        };
                    },
                    error: function(error) {
                        var rawError = new Error();
                        var x = utils.processError(error, rawError, null);
                        utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                        res.send(error.toString());
                    }
                });
            } else {
                response.success("Schedule mode does not allow generation at this time.");
            };
        },
        error: function(error) {
            var rawError = new Error();
            var x = utils.processError(error, rawError, null);
            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
            res.send(error.toString());
        }
    });
};

exports.dayDelete = function (req, res) {
    var query = new Parse.Query("SpecialKeyStructure");
    query.equalTo("key", "scheduleMode");
    query.first({
        success: function(object) {
            var date = new Date();
            if (date.getDay() != 0 && date.getDay() != 1) {
                //Continue...
                var firstQuery = new Parse.Query("SchoolDayStructure");
                firstQuery.equalTo("isActive", 1);
                firstQuery.ascending("schoolDayID");
                firstQuery.first().then(function(day) {
                    if (day.get("isSnow") == 0) {
                        //Wasn't a snow day the day before...you can delete this one
                        var query = new Parse.Query("SchoolDayStructure");
                        query.equalTo("isActive", 1);
                        query.ascending("schoolDayID");
                        query.first({
                            success: function(object) {
                                var schoolDate = object.get("schoolDate");
                                var now = moment().format("MM-DD-YYYY");
                                var theDate = moment(schoolDate, "MM-DD-YYYY");
                                var now = moment();
                                var test = theDate.isAfter(now);
                                if (schoolDate == now || test) {
                                    res.send("Date does not allow deletion at this time.");
                                } else {
                                    object.set("isActive", 0);
                                    object.save(null, {
                                        success: function(myObject) {
                                            res.send("SUCCESS");
                                        },
                                        error: function(myObject, error) {
                                            var rawError = new Error();
                                            var x = utils.processError(error, rawError, null);
                                            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                                            res.send(error.toString());
                                        }
                                    });
                                };
                            },
                            error: function(error) {
                                var rawError = new Error();
                                var x = utils.processError(error, rawError, null);
                                utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                                res.send(error.toString());
                            }
                        });
                    } else {
                        var rawError = new Error();
                        var x = utils.processError(error, rawError, null);
                        utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                        res.send(error.toString());
                    };
                });
            } else {
                res.send("Schedule mode does not allow deletion at this time.");
            };
        },
        error: function(error) {
            var rawError = new Error();
            var x = utils.processError(error, rawError, null);
            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
            res.send(error.toString());
        }
    });
};

exports.ECUdelete = function (req, res) {
    var query = new Parse.Query("ExtracurricularUpdateStructure");
    query.ascending("extracurricularUpdateID");
    query.find({
        success: function(structures) {
            for (var i = 0; i < structures.length; i++) {
                var currentStructure = structures[i];
                var thisDate = currentStructure.get("updatedAt");
                var now = new Date();
                var one_day=1000*60*60*24;
                var date1_ms = thisDate.getTime();
                var date2_ms = now.getTime();
                var difference_ms = date2_ms - date1_ms;
                difference_ms = Math.round(difference_ms/one_day);
                if (difference_ms >= 5) {
                    currentStructure.destroy({
                        success: function() {
                            console.log("Just deleted an object!!!");
                        },
                        error: function(error) {
                            var rawError = new Error();
                            var x = utils.processError(error, rawError, null);
                            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
                            res.send(error.toString());
                        }
                    });
                };
                if (i == structures.length - 1) {
                    res.send("SUCCESS");
                };
            }
            if (structures.length == 0) {
                res.send("No updates to delete!!!");
            };
        },
        error: function() {
            var rawError = new Error();
            var x = utils.processError(error, rawError, null);
            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
            res.send(error.toString());
        }
    });
};