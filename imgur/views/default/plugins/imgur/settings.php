<?php
/**
 * 	@package 	Imgur
 *	@version 	3.0
 * 	@author 	Cim 
 *  @link 		https://github.com/demyxco/elgg
 */

$client_id = elgg_get_plugin_setting('client_id', 'imgur');

?>

<p>
	<label><?php echo elgg_echo('imgur:clientid'); ?></label>
	<input type="text" name="params[client_id]" value="<?php echo $client_id ?>"></input>
</p>

<p style="margin-bottom: 20px">
	<?php echo elgg_echo('imgur:link'); ?>
</p>