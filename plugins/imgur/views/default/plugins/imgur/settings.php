<?php
/**
 *	@package	Imgur
 *	@version 	3.0
 *	@author 	Cim 
 *	@link 		https://github.com/demyxco/elgg
 */

$old_client_id = elgg_get_plugin_setting('client_id', 'imgur');
$client_id = elgg_get_plugin_setting('imgur_client_id', 'imgur');

?>

<?php if ($old_client_id) { elgg_require_js('imgur/update'); ?>
	<span class="imgur-settings-loading">
		Loading...
	</span>
	<div class="imgur-settings-container">
		<p>
			<?php echo elgg_echo('imgur:updatenotice'); ?>
		</p>

		<p>
			<?php 
				echo elgg_view('input/button', [
					'id' => 'imgur-update',
					'class' => 'elgg-button-submit',
					'value' => elgg_echo('imgur:updatebutton')
				]);
			?>
		</p>
		<style>
			.elgg-form-footer, .imgur-settings-container {
				display: none;
			}
		</style>
	</div>
<?php } else { ?>
	<p>
		<label><?php echo elgg_echo('imgur:clientid'); ?></label>
		<input type="text" name="params[imgur_client_id]" value="<?php echo $client_id ?>"></input>
	</p>

	<p style="margin-bottom: 20px">
		<?php echo elgg_echo('imgur:link'); ?>
	</p>
<?php } ?>