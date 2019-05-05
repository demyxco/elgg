<?php
/**
 *	@package	Blog Cover Photo
 *	@version 	3.1
 *	@author 	Cim 
 *	@link 		https://github.com/demyxco/elgg
 */

elgg_require_js('blogcoverphoto/update');

?>

<div class="blogcoverphoto-settings-container">
	<p>
		<?php echo elgg_echo('blogcoverphoto:updatenotice'); ?>
	</p>

	<p>
		<?php 
			echo elgg_view('input/button', [
				'id' => 'blogcoverphoto-update',
				'class' => 'elgg-button-submit',
				'value' => elgg_echo('blogcoverphoto:updatebutton')
			]);
		?>
	</p>
</div>

<span class="blogcoverphoto-settings-loading">
	Loading...
</span>

<style>
	.elgg-form-footer, .blogcoverphoto-settings-container {
		display: none;
	}
</style>