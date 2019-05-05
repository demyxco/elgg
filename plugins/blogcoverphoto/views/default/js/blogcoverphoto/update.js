/**
 *	@package	Blog Cover Photo
 *	@version 	3.1
 *	@author 	Cim 
 *	@link 		https://github.com/demyxco/elgg
 */

define(['require', 'jquery', 'elgg', 'elgg/spinner', 'elgg/Ajax'], function(require, $, elgg, spinner, Ajax) {
	$('.blogcoverphoto-settings-container').show();
	$('.blogcoverphoto-settings-loading').hide();
	var ajax = new Ajax();

	$('#blogcoverphoto-update').on('click', function() {
		$('.elgg-page-admin').hide();
		spinner.start();

		ajax.view('blogcoverphoto/update', {
			data: {},
		}).done(function (output, statusText, jqXHR) {
			if (jqXHR.AjaxData.status == -1) {
				return;
			}
			elgg.system_message(elgg.echo('blogcoverphoto:updatedone'));
			$('.elgg-page-admin').show();
			spinner.stop();
		});
	});
});