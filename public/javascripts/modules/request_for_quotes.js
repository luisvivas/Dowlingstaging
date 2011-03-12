jQuery.fn.deleteItem = function(link) {
	this.each(function() {
		jQuery('.item_form', this).toggleClass("hide");
		if($(this).data('deleted')) {
			//undelete
			$('input.destroy_item', this).val(0);
			$(this).data('deleted', false);
			$(link).html("Delete");
		} else {
			$('input.destroy_item', this).val(1);
			$(this).data('deleted', true);
			var str = "Undelete "+$('input.item_name', this).val();
			$(link).html(str);
		}
	});
};

jQuery(function($) {
	$('.delete_item').live('click', function(e) {
		$(this).parent().deleteItem(this);
	});
	
	$('.add_item').click(function(e) {
		e.preventDefault();
		var item_index = $(".item", $(this).parent()).length - 1;
		var scope_index = parseInt( $(this).attr('data-scope-of-work-id'), 10);
		var template = $('<div class="item"></div>').html($('#scope_item_form_template .item').clone());
		template = template.html().replace(/NEW_CHILD_RECORD/g, item_index+1).replace(/NEW_PARENT_RECORD/g, scope_index);
		$(this).before(template);
	});
});