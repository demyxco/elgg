<?php
/**
 *	@package	Blog Cover Photo
 */

// Load primary AMD module
elgg_require_js('blogcoverphoto/blogcoverphoto');

$blog = get_entity($vars['guid']);
$cover = $blog->blogcoverphoto_url;

// Set our hidden cover url input
$cover_field = [
	'#type' => 'url',
	'name' => 'blogcoverphoto_url',
	'required' => false,
	'id' => 'blogcoverphoto_url',
	'value' => $cover,
	'hidden' => true
];
echo elgg_view_field($cover_field);

// Main container for drag and drop with preview
echo '<div class="blogcoverphoto-dropzone-container" style="display: none">';
if ($cover == '' || $cover == null) {
	$cover_delete = elgg_view('output/url', [
		'href' => '#',
		'text' => elgg_echo('blogcoverphoto:delete'),
		'class' => 'elgg-button elgg-button-delete float-alt blogcoverphoto-delete',
		'confirm' => false,
		'hidden' => true
	]);
	echo '
		<div class="imgur-dropzone blogcoverphoto-dropzone">
			<div class="imgur-info blogcoverphoto-info"></div>
		</div>
	';
}
else {
	$cover_delete = elgg_view('output/url', [
		'href' => '#',
		'text' => elgg_echo('blogcoverphoto:delete'),
		'class' => 'elgg-button elgg-button-delete float-alt blogcoverphoto-delete',
		'confirm' => false,
	]);
	echo '
		<div class="imgur-dropzone blogcoverphoto-dropzone" style="background-image: url('.$cover.')">
			<div class="imgur-info blogcoverphoto-info" style="display: none"></div>
		</div>
	';
}
echo $cover_delete;
echo '</div>';