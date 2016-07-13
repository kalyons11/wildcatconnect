Parse.Cloud.define('saveGroupUpdates', function(request, response) {
	var groupArray = request.params.groupArray;
	Parse.Object.saveAll(groupArray, {
		success: function(objects) {
			response.success("Process complete.");
		},
		error: function(objects, error) {
			response.error(error);
		}
	});
});