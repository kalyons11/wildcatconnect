var utils = require("./utils/cloud-utils.js");
var ejs = require("ejs");
var pathModule = require("path");
var fs = require("fs");

Parse.Cloud.define('registerUser', function(request, response) {
    try {
    var query = new Parse.Query("UserRegisterStructure");
    query.equalTo("username", request.params.username);
    query.first({
        success: function(object) {
            var password = object.get("password");
            var realPass = utils.decrypt(password);

            var username = object.get("username");
            var email = object.get("email");
            var firstName = object.get("firstName");
            var lastName = object.get("lastName");
            var key = object.get("key");

            var theUser = new Parse.User();

            theUser.set("username", username);
            theUser.set("password", realPass);

            theUser.set("email", email);
            theUser.set("userType", "Faculty");
            theUser.set("ownedEC", new Array());
            theUser.set("firstName", firstName);
            theUser.set("lastName", lastName);
            theUser.set("verified", 0);
            theUser.set("key", key);
            theUser.signUp(null, {
                success: function (user) {
                    object.destroy({
                        success: function() {
                            var filePath = pathModule.join(__dirname, "./mail", "verify.ejs");
                            utils.log("info", filePath, null);
                            var templateContent = fs.readFileSync(filePath, 'utf8');
                            utils.log("info", templateContent, null);
                            var model = {
                                name: firstName + " " + lastName,
                                username: username,
                                key: key
                            };
                            model.page = {};
                            model.page.configurations = config.page;
                            var html = ejs.render(templateContent, { model: model });
                            utils.log("info", html, null);
                            utils.sendEmail(email, config.page.teamMailString, null, "team@wildcatconnect.com", config.page.applicationName + " Account Confirmation", html, true, null);
                            response.success("SUCCESS");
                        },
                        error: function(error) {
                            response.error(error);
                        }
                    });
                }, error: function(error) {
                    response.error(error);
                }
            });
        },
        error: function (error) {
            utils.log('error', "Error in Cloud Code.", [ error ]);
            response.error("!!!");
        }
    }); } catch (e) { response.error(e); }
});

Parse.Cloud.define('deleteUser', function(request, response) {
    var query = new Parse.Query("User");
    query.equalTo("username", request.params.username);
    query.first({
        success: function(user) {
            user.destroy({
                useMasterKey: true,
                success: function (done) {
                    response.success("SUCCESS!");
                },
                error: function (error) {
                    response.error(error);
                }
            });
        },
        error: function(error) {
             response.error(error);
        }
    });
});

Parse.Cloud.define("updateUser", function(request, response) {
    var query = new Parse.Query("User");
    query.equalTo("username", request.params.username);
    var type = request.params.type;
    query.first({
        success: function (user) {
            user.set("userType", type);
            user.save(null, {
                useMasterKey : true,
                success: function (object) {
                    response.success("SUCCESS");
                }, error: function (object, error) {
                    response.error(error);
                }
            });
        }, error: function (error) {
            response.error(error);
        }
    });
});

Parse.Cloud.define("updateEmail", function(request, response) {
    var query = new Parse.Query("User");
    query.equalTo("username", request.params.username);
    query.first({
        success: function (user) {
            user.save({ email: request.params.email }, {
                useMasterKey: true,
                success: function (final) {
                    response.success("SUCCESS");
                }, error: function (error) {
                    response.error(error);
                }
            });
        }, error: function (error) {
            response.error(error);
        }
    });
});

Parse.Cloud.define("countInstallations", function(request, response) {
    var query = new Parse.Query("_Installation");
    query.count({
        useMasterKey: true,
        success: function(count) {
            response.success(count);
        },
        error: function(error) {
            response.error(error);
        }
    });
});

Parse.Cloud.define("verifyUser", function(request, response) {
    var username = request.params.username;
    var query = new Parse.Query("User");
    query.equalTo("username", username);
    query.first({
        success: function(user)  {
            user.set("verified", 1);
            user.save(null, {
                useMasterKey: true,
                success: function(finalUser)  {
                    response.success("SUCCESS");
                }, error: function(error) {
                    response.error(error);
                }
            });
        }, error: function(error) {
            response.error(error);
        }
    });
});

Parse.Cloud.define("updateLinks", function(request, response) {
    console.log("Yup1.");
    var query = new Parse.Query("UsefulLinkArray");
    query.find({
        success: function(objects) {
            // Data in request.params.data
            console.log("Yup1.");
            var data = request.params.data;
            console.log("Bool test..." + data != null);
            var updateArray = new Array();
            var addArray = new Array();
            var deleteArray = new Array();
            for (var i = 0; i < data.length; i++) {
                var thisOne = data[i];
                if (utils.containsObject(thisOne["objectId"], objects))
                    updateArray.push(thisOne);
                else
                    addArray.push(thisOne);
            }
            for (var j = 0; j < objects.length; j++) {
                if (! utils.containsObject(objects[i]["objectId"], data))
                    deleteArray.push(objects[i]);
            }
            console.log("Yup2.");
            Parse.Object.destroyAll(deleteArray, {
                success: function(next){
                    // Update new fields
                    console.log("Yup3.");
                    for (var index = 0; index < updateArray.length; index++) {
                        var objectToSave = updateArray[index];
                        objectToSave.save(null, {
                            success: function(done) {
                                console.log("Yup1.");
                            }, error: function (error) {
                                response.error(error);
                            }
                        });
                    }
                    // Save new objects too
                    for (var index = 0; index < newArray.length; index++) {
                        var objectToSave = newArray[index];
                        objectToSave.save(null, {
                            success: function(done) {
                                console.log("Yup77.");
                                if (index == newArray.length - 1) {
                                    console.log("Yup999.");
                                    response.success("SUCCESS");
                                }
                            }, error: function (error) {
                                response.error(error);
                            }
                        });
                    }
                }, error: function (error) {
                    response.error(error);
                }
            });
        }, error: function (error) {
            response.error(error);
        }
    });
});

Parse.Cloud.afterSave("ExtracurricularUpdateStructure", function(request) {
    if (request.object.get("extracurricularUpdateID") != null) {
        increment();
        var query = new Parse.Query("ExtracurricularStructure");
        query.equalTo("extracurricularID", request.object.get("extracurricularID"));
        query.first({
            success: function(structure) {
                var title = structure.get("titleString");
                var channelString = "E" + structure.get("extracurricularID").toString();
                Parse.Push.send({
                    channels: [ channelString ],
                    data: {
                        alert: title + " - " + request.object.get("messageString"),
                        e: "e",
                        badge: "Increment"
                    }
                });
            },
            error: function(error) {
                //Handle error
            }
        });
    };
});

Parse.Cloud.afterDelete("ExtracurricularStructure", function(request) {
    var ID = request.object.get("extracurricularID");
    var channelString = "E" + ID.toString();
    Parse.Cloud.useMasterKey();
    var query = new Parse.Query("_Installation");
    query.equalTo("channels", channelString);
    var finalArray = new Array();
    query.find({
        success: function(users) {
            console.log("HERE" + users.length);
            for (var i = 0; i < users.length; i++) {
                var theString = users[i].get("channels");
                var array = Object.keys(theString).map(function (key) {return theString[key]});
                var index = array.indexOf(channelString);
                if (index > -1) {
                    array.splice(index, 1);
                    users[i].set("channels", array);
                    finalArray.push(users[i]);
                };
            }
            Parse.Object.saveAll(finalArray, {
                success: function(savedObjects) {
                    //
                },
                error: function(error) {
                    //
                }
            });
        }, error: function(error) {
            //
        }
    });
    var queryTwo = new Parse.Query("_User");
    queryTwo.equalTo("ownedEC", ID);
    var finalArray = new Array();
    queryTwo.find({
        success: function(users) {
            for (var i = 0; i < users.length; i++) {
                var theString = users[i].get("ownedEC");
                var array = Object.keys(theString).map(function (key) {return theString[key]});
                var index = array.indexOf(ID);
                if (index > -1) {
                    array.splice(index, 1);
                    users[i].set("ownedEC", array);
                    finalArray.push(users[i]);
                };
            }
            Parse.Object.saveAll(finalArray, {
                success: function(savedObjects) {
                    //
                },
                error: function(error) {
                    //
                }
            });
        },
        error: function(error) {
            //
        }
    });

    var queryThree = new Parse.Query("ExtracurricularUpdateStructure");
    queryThree.equalTo("extracurricularID", ID);
    queryThree.find({
        success: function(updates) {
            Parse.Object.destroyAll(updates, {
                success: function(deletedObjects) {

                },
                error: function(error) {

                }
            })
        },
        error: function(error) {
            //
        }
    });

});

Parse.Cloud.afterSave("CommunityServiceStructure", function(request) {
    if (request.object.get("communityServiceID") != null && request.object.get("isApproved") == 1) {
        increment();
        Parse.Push.send({
            channels: [ "allCS" ],
            data: {
                alert: "COMMUNITY SERVICE - " + request.object.get("commTitleString"),
                c: "c",
                badge: "Increment"
            }
        });
    };
});

Parse.Cloud.beforeSave("PollStructure", function(request, response) {
    //Not first save...sum responses from individual choices...
    var dictionary = request.object.get("pollMultipleChoices");
    var sum = 0;
    for (var key in dictionary) {
        sum += parseInt(dictionary[key], 10);
    }
    if (sum && sum > 0) {
        request.object.set("totalResponses", sum.toString());
    } else {
        request.object.set("totalResponses", "0".toString());
    };
    response.success();
});

Parse.Cloud.afterSave("PollStructure", function(request) {
    if (request.object.get("pollID") != null && request.object.get("totalResponses") === "0") {
        increment();
        Parse.Push.send({
            channels: [ "allPolls" ],
            data: {
                title: "WildcatConnect",
                alert: "POLL - " + request.object.get("pollTitle"),
                p: request.object.get("pollID"),
                badge: "Increment"
            }
        });
    };
});

Parse.Cloud.beforeSave("NewsArticleStructure", function(request, response) {
    if (request.object.get("articleID") != null && request.object.get("views") == 0 && request.object.get("isApproved") === 1) {
        increment();
        Parse.Push.send({
            channels: [ "allNews" ],
            data: {
                title: "WildcatConnect",
                alert: "NEWS - " + request.object.get("titleString"),
                n: request.object.get("articleID"),
                badge: "Increment"
            }
        }, {
            success: function() {
                response.success("Done!");
            },
            error: function(error) {
                response.error(error);
            }
        });
    } else {
        response.success("");
    };
});

Parse.Cloud.afterSave("AlertStructure", function(request) {
    if (request.object.get("alertID") != null) {
        increment();
        if (request.object.get("isReady") == 1 && request.object.get("views") == 0) {
            var query = new Parse.Query("SpecialKeyStructure");
            query.equalTo("key", "appActive");
            query.first({
                success: function(structure) {
                    if (structure.get("value") === "1") {
                        Parse.Push.send({
                            channels: [ "global" ],
                            data: {
                                title: "WildcatConnect",
                                alert: request.object.get("titleString"),
                                a: request.object.get("alertID"),
                                badge: "Increment"
                            }
                        });
                    };
                },
                error: function(errorTwo) {
                    response.error("Error.");
                }
            });
        };
    };
});

Parse.Cloud.afterSave("EventStructure", function (request) {
    increment();
});

function increment() {
    var query = new Parse.Query("ContentStructure");
    query.first({
        success: function(object) {
            var value = object.get("value");
            object.set("value", value + 1);
            object.save();
        }, error: function(error) {
            var rawError = new Error();
            var x = utils.processError(error, rawError, null);
            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
            res.send(error.toString());
        }
    });
}