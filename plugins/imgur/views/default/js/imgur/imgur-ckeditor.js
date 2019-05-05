/**
 *	@package	Imgur
 *	@version 	3.0
 *	@author 	Cim 
 *	@link 		https://github.com/demyxco/elgg
 */

define(['require', 'jquery', 'elgg'], function(require, $, elgg) {
	// Imgur callback
	var imgur_feedback = function(res) {
		if (res.success === true) {
			var get_link = res.data.link.replace(/^http:\/\//i, 'https://');
			$('form').find('.cke_wysiwyg_frame').contents().find('body').append('<img src="'+get_link+'" />');
		}
	};
	// Initiate Imgur asset with Client ID
	new Imgur({
		clientid: elgg.data.imgur.imgur_client_id,
		callback: imgur_feedback,
		dropzone: '.imgur-main-dropzone',
		info: '.imgur-main-info'
	});
	// Show Imgur upload box
	$('.imgur-dropzone').show();
});