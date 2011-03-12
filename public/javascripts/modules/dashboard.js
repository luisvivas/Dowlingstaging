jQuery(function($) {
	var container = $('#added_work_orders');
	if(container.length > 0) {
		var added_items = {};
		var parent = $("#work_order_picker");
		var child = $('#work_order_item_picker');
		var add_button = $('#add_work_order');
		var interactive = child.add(add_button);

		function getSelectedDetails() {
			return [parent.val(), child.val()];
		};
		function getSelectedSlug() {
			return getSelectedDetails().join('_');
		};
		parent.change(function() {
			interactive.attr('disabled', 'disabled');
		});

		child.chainedSelect({
			parent: parent,
			preloadUrl: IMAGE_LOADER_URL,
			value: 'id',
			label: 'text',
			url: '/work_orders/quote_items',
			initialLoad: false
		}).change(function() {
			interactive.removeAttr('disabled');
		});
		var quote_item_index = 0;
		var add_floaty = $("#add_floaty");
		
		add_button.click(function(e) {
			if(!(getSelectedSlug() in added_items)) {
				var wo_container = "work_order_"+parent.val();
				var cont = $("#"+wo_container, container);
				
				if(cont.length == 0) {
					cont = $("<div id=\""+wo_container+"\"><h2>"+$(':selected', parent).text()+"</h2></div>").appendTo(container);
				}
				
				var load_into = $("<div id=\""+getSelectedSlug()+"\"><h3>"+$(':selected', child).text()+" Loading ... </h3></div>").appendTo(cont);
				
				jQuery.ajax({
					url: '/work_orders/'+parent.val()+'/end_of_day_reports/'+child.val(),
					type: "GET",
					dataType: "html",
					complete: function( res, status ) {
						if ( status === "success" || status === "notmodified" ) {
							load_into.html(jQuery("<div />").append(res.responseText.replace(/NEW_RECORD/g, quote_item_index)).find(".end_of_day"));
							quote_item_index = quote_item_index + 1;
							add_floaty.position({
								my: "top",
								at: "bottom",
								of: "#add_new_destination"
							});
						}
					}
				});
				
				added_items[getSelectedSlug()] = true;
			}
		});
		
		$('input.completion').live('change', function(e) {
			var avail = parseFloat($(this).parent().prev()[0].innerHTML);
			var cons = parseFloat($(this).val());
			var v = avail-cons;
			var display = v < 0 ? 0 : v;
			$(this).parent().next().html_highlight($.round_two(display));
		});
		
		$('input.added_completion').live('change', function(e) {
			var already_cons 	= parseFloat($(this).parent().prev()[0].innerHTML);
			var today_cons		= parseFloat($(this).val());
			var v = (already_cons + today_cons);
      
			var avail 			  = parseFloat($(this).parent().prev().prev()[0].innerHTML);
      if(avail > 0) {
			  var display = avail-v < 0 ? 0 : avail-v;
			  $(this).parent().next().html_highlight($.round_two(display));
      }
			
      $(this).next().val(v);
			var desc = $(this).parent().parent().next();
      if(today_cons > 0) {
				desc.show();
			} else {
				desc.hide();
			}
		});
		
		$('input.total_contributor').live('change', function(e) {
			total = $('input.total_contributor').inject(0, function(sum) {
				if($(this).val() != "") {
					sum += parseFloat($(this).val());	
				}
				return sum;
			});
			// $("#total_hours").html_highlight("Total hours worked: "+total);
		});
	}
});
