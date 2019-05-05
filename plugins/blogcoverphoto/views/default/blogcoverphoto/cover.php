<?php
/**
 *	@package	Blog Cover Photo
 *	@version 	3.0
 *	@author 	Cim 
 *	@link 		https://github.com/demyxco/elgg
 */

$full = elgg_extract('full_view', $vars, FALSE);
$blog = elgg_extract('entity', $vars, FALSE);
$cover = $blog->blogcoverphoto_url;

// Show cover if full view
if ($full && $cover) {
	echo '
		<div class="blogcoverphoto-cover" style="background-image: url('.$cover.')"></div>
	';
}

// Show cover on river and non full views
if (!$full && $cover) {
	echo '
		<a href="'.$blog->getURL().'">
			<div class="blogcoverphoto-river" style="background-image: url('.$cover.')"></div>
		</a>
	';
}