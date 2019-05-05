/**
 *	@package	Blog Cover Photo
 *	@version 	3.1
 *	@author 	Cim 
 *	@link 		https://github.com/demyxco/elgg
 */

define(['require', 'jquery', 'elgg'], function(require, $, elgg) {
	// Imgur callback
	var blogcoverphoto_feedback = function(blogcoverphoto_res) {
		if (blogcoverphoto_res.success === true) {
			var blogcoverphoto_url = blogcoverphoto_res.data.link.replace(/^http:\/\//i, 'https://');
			$('input[name=blogcoverphoto_url]').val(blogcoverphoto_url);
			$('.blogcoverphoto-dropzone').css('background-image', 'url('+blogcoverphoto_url+')');
			$('.blogcoverphoto-delete').removeAttr('hidden');
			$('.blogcoverphoto-info').hide();
		}
	};
	// Initiate Imgur asset with Client ID
	new Imgur({
		clientid: elgg.data.imgur.imgur_client_id,
		callback: blogcoverphoto_feedback,
		dropzone: '.blogcoverphoto-dropzone',
		info: '.blogcoverphoto-info',
		message: elgg.echo('blogcoverphoto:covermessage')
	});
	// Show upload box
	$('.blogcoverphoto-dropzone-container').show();
	// Delete cover logic
	$('.blogcoverphoto-delete').on('click', function(e) {
		e.preventDefault();
		$(this).attr('hidden', true);
		$('input[name=blogcoverphoto_url]').val('');
		$('.blogcoverphoto-dropzone').css('background-image', 'url("")');
		$('.blogcoverphoto-info').show();
	});
});