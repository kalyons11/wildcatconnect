var utils = require("./utils/cloud-utils.js");

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
                            var text = firstName + ", \n\nYour new WildcatConnect account has been approved! With your faculty account, you will now be able to log in to both the WildcatConnect iOS App and our web portal at http://www.wildcatconnect.com. For your first login, you will be required to enter the following credentials...\n\nUsername = " + username + "\nPassword = The password you created during registration...\n\n***Registration Key = " + key +"\n\nNOTE: All usernames, passwords and keys are case-sensitive.\n\nEnjoy posting and sharing with students, faculty and families!\n\nBest,\n\nWildcatConnect Development Team\n\nWeb: http://www.wildcatconnect.com\nSupport: support@wildcatconnect.com\nContact: team@wildcatconnect.com\n\n---\n\nIf you did not register an account and are receiving this e-mail in error, please contact us immediately at support@wildcatconnect.com. For security purposes, your registration key will expire in 72 hours, at which time you will need to re-register your account.\n";
                            utils.sendEmail(email, "WildcatConnect <team@wildcatconnect.com>", null, "team@wildcatconnect.com", "WildcatConnect Account Confirmation", text, false, null);
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
    utils.log("info", "Query initialized.", null);
    query.first({
        success: function(user) {
            utils.log("info", "Got user object.", null);
            user.destroy({
                success: function (done) {
                    utils.log("info", "Deleted user!", null);
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