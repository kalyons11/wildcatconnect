var type = process.argv[process.argv.length - 2];

switch (type) {
    case "string":
        var input = process.argv[process.argv.length - 1];

        console.log(input);

        var utils = require("./utils");

        var result = utils.decrypt(input);

        console.log(result);

        break;

    case "object":
        var input = process.argv[process.argv.length - 1];

        console.log(input);

        var utils = require("./utils");

        var result = utils.decryptObject(input);

        console.log(result);

        break;
}