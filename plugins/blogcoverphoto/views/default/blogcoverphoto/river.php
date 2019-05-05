<?php
/**
 *	@package	Blog Cover Photo
 *	@version 	3.0
 *	@author 	Cim 
 *	@link 		https://github.com/demyxco/elgg
 */

// Get blog river items
$item = elgg_extract('item', $vars);
if (!$item instanceof ElggRiverItem) {
	return;
}
$blog = $item->getObjectEntity();
if (!$blog instanceof ElggBlog) {
	return;
}

// Output cover to river entities
$cover = $blog->blogcoverphoto_url;
if ($cover) {
	echo '
		<a href="'.$blog->getURL().'">
			<div class="blogcoverphoto-river" style="background-image: url('.$cover.')"></div>
		</a>
	';
}