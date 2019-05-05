<?php
/**
 *	@package	Imgur
 *	@version 	3.0
 *	@author 	Cim 
 *	@link 		https://github.com/demyxco/elgg
 */

elgg_register_event_handler('init','system','imgur_init');
elgg_register_plugin_hook_handler('elgg.data', 'site', 'imgur_client_id');

function imgur_init() {
	// Get Imgur client ID
	$client_id = elgg_get_plugin_setting('imgur_client_id', 'imgur');
	
	// Load assets
	elgg_extend_view('elgg.css', 'imgur.css');
	elgg_extend_view('elgg.js', 'imgur.js');

	if ($client_id) {
		// Deploy hidden imgur upload input
		elgg_extend_view('input/longtext', 'imgur/init');
	}
}

function imgur_client_id($hook, $type, $value, $params) {
	// Store Client ID so we can get it via JS
	$value['imgur']['client_id'] = elgg_get_plugin_setting('imgur_client_id', 'imgur');
	return $value;
}