var utils = require('../utils/utils');

exports.handleJob = function(req, res) {
   if (req.body.secret == utils.decrypt(global.config.jobSecret)) {
        var name = req.params.name;
        switch (name) {
            case "test":
                res.send("YES!!!");
            case "newsDelete":
                return exports.newsDelete(req, res);
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
                            var x = utils.processError(e, rawError, null);
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
        error: function() {
            var rawError = new Error();
            var x = utils.processError(e, rawError, null);
            utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
            res.send(error.toString());
        }
    });
};