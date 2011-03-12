jQuery.fn.deleteSize = function(link) {
	this.each(function() {
		jQuery('.size_form', this).toggleClass("hide");
		if($(this).data('deleted')) {
			//undelete
			$('input.destroy_size', this).val(0);
			$(this).data('deleted', false);
			$(link).html("Delete");
		} else {
			$('input.destroy_size', this).val(1);
			$(this).data('deleted', true);
			var str = "Undelete "+$('.size_name input', this).val();
			$(link).html(str);
		}
	});
};

jQuery(function($) {
	$('.delete_size').live('click', function(e) {
		$(this).parent().deleteSize(this);
	});
	
	$('.add_size').click(function(e) {
		e.preventDefault();
		var index = parseInt($('.inplay .size:last .size_name input').attr('name').replace(/[^0-9]/g,''), 10);
		var template = $('<div class="size"></div>').html($('#size_form_template form .size').clone());
		template = template.html().replace(/NEW_RECORD/g, index+1);
		$(this).parent().before(template);
	});

	$('.product_type_changer').change(function(e) {
		var amount_text = "Weight";
		var amount_suffix = "lbs";
		var name = $(this).val();
		if(name == "SheetProduct") {
			amount_text = "Weight per sq ft";
			amount_suffix = "lbs/sq ft";
		} else if(name == "LengthProduct") {
			amount_text = "Weight per ft";
			amount_suffix = "lbs/ft";
		} else if(name == "UnitProduct") {
			amount_text = "Cost per Unit";
			amount_suffix = "$";
		};
		$(".product_amount_title").html(amount_text);
		$(".product_amount_suffix").html(amount_suffix);
	}).trigger('change');
});