$(document).on('click', '.nav-sidebar li', function() {
   $(".nav-sidebar li").removeClass("active");
   $(this).addClass("active");
});

function setLoadingMessage(string) {
	$("#loading").find("h1").html(string);
};

function setMessage(message, isError) {
    if (isError)
        $("#messages").html('<div class="alert alert-danger fade in"><span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span><strong>Error: '+message+'</strong></div>');
    else
        $("#messages").html('<div class="alert alert-success fade in"><span class="glyphicon glyphicon-check" aria-hidden="true"></span><strong>Message: '+message+'</strong></div>');
};