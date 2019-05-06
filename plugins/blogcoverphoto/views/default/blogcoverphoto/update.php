<?php
/**
 *	@package	Blog Cover Photo
 */

elgg_ajax_gatekeeper();

$entities = elgg_get_entities(array(
	'type' => 'object',
	'subtype' => 'blog',
	'limit' => 999999,
));

foreach ($entities as $entity) {
	if ($entity->cover_url) {
		$entity->blogcoverphoto_url = $entity->cover_url;
		$entity->cover_url = '';
	}
}