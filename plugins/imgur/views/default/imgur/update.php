<?php
/**
 *	@package	Imgur
 *	@version 	3.0
 *	@author 	Cim 
 *	@link 		https://github.com/demyxco/elgg
 */

elgg_ajax_gatekeeper();

// Migrate old metadata
$old_meta = elgg_get_plugin_setting('client_id', 'imgur');

// Import old metadata
elgg_set_plugin_setting('imgur_client_id', $old_meta, 'imgur');

// Set old metadata to null
elgg_set_plugin_setting('client_id', '', 'imgur');