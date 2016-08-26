var Test = require('../models/test.js');

exports.view = function(req, res) {
	var model = new Test();
	model.object.viewMode = 'post';
	model.renderModel();
	model.page.title = "New Test Object";
	res.render("test", { model : model });
};

exports.post = function(req, res) {
	var obj = new Test();
	obj.object.name = req.body.name;
	obj.object.id = req.body.id;
	obj.object.data = {
		age: req.body.age,
		link: req.body.link
	};
	obj.object.created = req.body.created;
	obj.object.updated = new Date();
	obj.object.viewMode = 'get';
	obj.renderModel();
	obj.page.title = obj.object.name;
	res.render("test", { model : obj });
};