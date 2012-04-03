$(document).ready(function(){
	$(".show-detail-button").click(function() {
		// $(this).siblings(".hidden-detail").slideToggle("fast");
		if ($(this).siblings(".hidden-detail").is(":visible")){
			$(this).html("more details");
			$(this).siblings(".hidden-detail").slideUp("fast");
		} else {
			$(this).html("less details");
			$(this).siblings(".hidden-detail").slideDown("fast");
		}
	});
});