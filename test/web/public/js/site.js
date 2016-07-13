$(document).on('click', '.nav-sidebar li', function() {
   $(".nav-sidebar li").removeClass("active");
   $(this).addClass("active");
});

function setLoadingMessage(string) {
	$("#loading").find("h1").html(string);
};