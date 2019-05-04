<?php
/**
 *	@package	Imgur
 *	@version 	3.0
 *	@author 	Cim 
 *	@link 		https://github.com/demyxco/elgg
 */

// Load module based on logic
if (elgg_is_active_plugin('ckeditor')) elgg_require_js('imgur/imgur-ckeditor');
if (elgg_is_active_plugin('extended_tinymce')) elgg_require_js('imgur/imgur-tinymce');

?>

<div class="imgur-dropzone">
    <div class="imgur-info"></div>
</div>
