/**
 *	@package	Imgur
 *	@version 	3.0
 *	@author 	Cim 
 *	@link 		https://github.com/demyxco/elgg
 */

define(['require', 'jquery', 'elgg', 'elgg/spinner', 'elgg/Ajax'], function(require, $, elgg, spinner, Ajax) {
	$('.imgur-settings-container').show();
	$('.imgur-settings-loading').hide();
	var ajax = new Ajax();

	$('#imgur-update').on('click', function() {
		$('.elgg-page-admin').hide();
		spinner.start();

		ajax.view('imgur/update', {
			data: {},
		}).done(function (output, statusText, jqXHR) {
			if (jqXHR.AjaxData.status == -1) {
				return;
			}
			elgg.system_message(elgg.echo('imgur:updatedone'));
			$('.elgg-page-admin').show();
			spinner.stop();
			location.reload();
		});
	});
});