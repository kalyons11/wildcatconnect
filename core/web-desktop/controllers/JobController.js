var utils = require('../utils/utils');

exports.handleJob = function(req, res) {
   if (req.body.secret == utils.decrypt(global.config.jobSecret)) {
        var name = req.params.name;
        switch (name) {
            case "test":
                res.send("YES!!!");
        }
    } else {
        utils.log("error", "Forbidden access detected from IP address: " + req.connection.remoteAddress, null);
        res.status(401).send("FORBIDDEN ACCESS");
    }
};