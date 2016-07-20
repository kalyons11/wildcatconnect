var input = process.argv[process.argv.length - 1];

console.log(input);

var utils = require("./utils");

var result = utils.encryptObject(input);

console.log(result);