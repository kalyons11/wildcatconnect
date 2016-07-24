var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var PageModel = require('./page.js');

var page = new PageModel({
    title: "Verify",
    configurations: {
        key: "Sample value."
    }
});

var verifySchema = new Schema({
    object : {
        key: String
    },
    page : { type: mongoose.Schema.ObjectId, ref: 'Page' }
});

verifySchema.methods.renderModel = function(username) {
    this.loadPageModel();
    this.initializeErrors();
    this.page.configurations.username = username;
};

verifySchema.methods.loadPageModel = function() {
    this.page = page;
};

verifySchema.methods.initializeErrors = function() {
    this.page.theErrors = new Array();
}

var Verify = mongoose.model('Verify', verifySchema);

module.exports = Verify;