<?php
/**
 *	@package	Blog Cover Photo
 *	@version 	3.0
 *	@author 	Cim 
 *	@link 		https://github.com/demyxco/elgg
 */

elgg_register_event_handler('init', 'system', 'blogcoverphoto_init');
elgg_register_event_handler('publish', 'object', 'blogcoverphoto_url');
elgg_register_event_handler('update', 'object', 'blogcoverphoto_url');

function blogcoverphoto_init() {
	// CSS
	elgg_extend_view('elgg.css', 'blogcoverphoto.css');

	// Extend blog entities with cover URL
	elgg_extend_view('object/blog', 'blogcoverphoto/cover', 0);
	elgg_extend_view('river/object/blog/create', 'blogcoverphoto/river', 0);

	// Extend blog forms with ours
	elgg_extend_view('forms/blog/save', 'blogcoverphoto/form', 0);
}

function blogcoverphoto_url($event, $object_type, $object) {
	// Save our custom metadata on blog creation/update
	if ($object_type = 'blog') {
		$guid = $object->getGUID();
		$blog = get_entity($guid);
		$blog->blogcoverphoto_url = get_input('blogcoverphoto_url');
	}
}