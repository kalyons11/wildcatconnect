var config = require("../config");
var utils = require("./utils");

var enc = utils.encryptObject(config);

var fs = require('fs');

fs.writeFile("../config_enc.js", 'module.exports = "' + enc + '";', function(err) {
    if(err) {
        console.log(err);
    } else {
        console.log("Encryption successful.");
    }
});