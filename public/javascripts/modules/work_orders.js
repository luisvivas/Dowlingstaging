jQuery.fn.orderAllCheckbox = function(watch_selector, default_container) {
	return this
	.each(function() {
		// Figure out the container to search for the watched boxes in
		// attribute takes precedence over function over this.parent
		var container;
		if($(this).attr('data-all-container')) {
			container = $($(this).attr('data-all-container'));
		} else {
			if(typeof default_container == 'function') {
				container = $.proxy(default_container, this)();
			} else {
				container = $(this).parent().parent().parent();
			}
		}
		// Store watched boxes
		$(this).data('watched', $(watch_selector, container));
		// Update self when watched boxes change
		$(this).data('watched').change($.proxy(function() {
			$(this).trigger('watch_change');
		}, this));	
	})
	.change(function() {
		// Update watched boxes when self changes
		$(this).data('watched').attr('checked', $(this).attr('checked')).trigger('change');	
	})
	.bind('watch_change', function() {
		// Update self when watches boxes change by checking to see if all the watched
		// boxes are checked, and if so, checking self.
		var all = true;
		$(this).data('watched').each(function() {
			if(!$(this).is(":checked")) {
				all = false;
			}
		});
		if(all) {
			$(this).attr("checked", true);
		} else {
			$(this).attr("checked", false);
		}
	})
	.trigger('watch_change');
};
jQuery(function($) {
	$('.order_all').orderAllCheckbox(".ordered:checkbox");
	$('.stock_all').orderAllCheckbox(".stocked:checkbox");
	$('.schedule_all').orderAllCheckbox(".scheduled:checkbox");
	$('.complete_all').orderAllCheckbox(".completed:checkbox");
});