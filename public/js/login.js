$(document).ready(function() {
	$("form").submit(function(event) {
		if( $("input:checked").length ) {
			return true;
		} else {
			event.preventDefault();
			$("#disclaimer").effect("shake",{times:4, distance: 10}, 50);
			return false;
		}
	});
});