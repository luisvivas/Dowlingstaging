var IMAGE_LOADER_URL = "/images/spinner.gif";

// Function to return the value of the selected option in a select.
jQuery.fn.selected_attr = function() {
	var sel = $('option:selected', this);
	return sel.attr.apply(sel, arguments);
};

// Function to return plugin object attached to an element
jQuery.fn.obj = function(object) {
	var that = jQuery(this);
	return that.data.call(that, 'plugin.obj', object);
};

// Function to update HTML of elements and highlight if changed
jQuery.fn.html_highlight = function(string, options, speed) {
	if(typeof options == "undefined") {
		options = {};
	}
	if(typeof speed == "undefined") {
		speed = 600;
	}
	if(this.html() != string) {
		this.html(string);
		this.effect("highlight", options, speed);
	}
};

jQuery.fn.html_highlight_error = function() {
	this.html_highlight("Error!", {color: "red", easing: "easeInCubic"}, 1500);
};
// Function to format amount as currency
jQuery.dollars = function(amt) {
	var num = Math.floor($.round_two(amt));
	var decimals = $.round_two(amt-num).toFixed(2).substring(1,4);
	num = String(num);
	for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3); i++) {
		num = num.substring(0, num.length - (4 * i + 3)) + "," + num.substring(num.length - (4 * i + 3));
	}
	return "$" + num + decimals;
};
jQuery.round_two = function(amt) {
	return Math.round(amt * 100)/100;
};
jQuery(function($) {
	//Striped Tables
	$('.stripeMe tr:even').addClass('alt');
	
	//Tabs
	$('.tabs').tabs();
	
	// Tool Tip
	$('.tooltip').tipTip();
	
	//Togglebox
	$(".togglebox").toggleboxes();
	
	$(".closed_togglebox").toggleboxes({active: false});
	
	// Datepicker
	$( "input.datepicker" ).datepicker();
	
	//Autocomplete
	$('input.quicksearch, input.helpertext').each(function() {
		var input = $(this);
		input.data('original_value', input.val());
	
		input.blur(function(e) {
			if(input.val() == "") {
				$(e.target).val(input.data('original_value'));
			}
			$(e.target).removeClass('focused');
		});
		input.focus(function(e) {
			if(input.val() == input.data('original_value')) {
				$(e.target).val("");
			}
			$(e.target).addClass('focused');
		});
	});

	$('input.autocomplete').each(function() {
		var input = $(this);
		var mustMatch = 1;
		
		if (input.hasClass('quicksearch')) {
			mustMatch = 0;
		}
		if (input.attr('data_must_match') == "false") {
			mustMatch = 0;
		}
		if (typeof input.attr('data_update') == 'string') {
			input.result(function(event, data, formatted) {
				$(input.attr('data_update')).val(data[0].split(" --- ")[1]);
				if(input.val() == "") {
					$(input.attr('data_update')).val("");
				}
			});
			input.change(function() {
				if(input.val() == "") {
					$(input.attr('data_update')).val("");
				}
			});
		}
		
		if(typeof input.attr('success_url') == 'string') {
			input.result(function(event, data, formatted) {
				var auto_url = input.attr('success_url')+"/"+data[0].split(" --- ")[1];
				if (typeof input.attr('success_update') == 'string' ) {
					$(input.attr('success_update')).html("<image src='"+IMAGE_LOADER_URL+"'>");
					$(input.attr('success_update')).load(auto_url);
				} else {
					window.location = auto_url;
				}
			});
		}	
		
		var extras = {};
		if(typeof input.attr('data_scoped_by') == "string") {
			extras.scope = function() {
				return $(input.attr('data_scoped_by')).val();
			};
		}
		var cache_length = $.Autocompleter.defaults.cacheLength;
		if(typeof input.attr('data_no_cache') == "string" || typeof input.attr('data_scoped_by') == "string") {
			cache_length = 0;
		}
		input.autocomplete(input.attr('autocomplete_url'), {
			matchContains: 1,
			//also match inside of strings when caching
			mustMatch: mustMatch,
			//allow only values from the list
			selectFirst: 1,
			//select the first item on tab/enter
			removeInitialValue: 0,
			//when first applying $.autocomplete
			formatItem: function(data, i, n, value) {
				return value.split(" --- ")[0];
			},
			formatMatch: function(data, i, n, value) {
				return value.split(" --- ")[0];
			},
			formatResult: function(data, value) {
				return value.split(" --- ")[0];
			},
			extraParams: extras,
			cacheLength: cache_length
		});
	});
	
	//Actions dropdown
	$('select.actions').each(function() {
		$(this).change(function() {
			if(this.selectedIndex !== 0) {
				window.location.href = $(this).val();
			}
			//window.location = $(this).val();
		});
	});
	
	//State Chained Select
	var selects = ['contact_address_attributes', 'business_address_attributes'];
	$.each(selects, function(i, select) {
		$('#'+select+'_state').chainedSelect({
			parent: '#'+select+'_country',
			url: '/states/',
			value: 'id',
			label: 'text'
		  });
	});
	
	//tableToGrid("table.jqgrid");
	
	$('.currency').formatCurrency();
	$('.long_currency').formatCurrency({roundToDecimalPlace:5});
	
	// Format all currency
	$('input.currency').live('blur', function() {
		$(this).formatCurrency();
	});
	$('input.long_currency').live('blur', function() {
		$(this).formatCurrency({roundToDecimalPlace:5});
	});
	
	$('form').live('submit', function(e) {
		$('.currency, .long_currency', this).toNumber();
		return true;
	});
	
	// Form change page leave warning
	var tracked_forms = $('form:not(.no_change_track):not(.no_submit)');
	var catcher = function() {
		var changed = false;
		tracked_forms.each(function() {
			if ($(this).data('initialForm') != $(this).serialize()) {
				changed = true;
				$(this).addClass('changed');
			} else {
				$(this).removeClass('changed');
			}
		});
		if (changed) {
			return "One or more forms have changed! If you leave this page, your changes won't be saved. Are you sure you want to leave?";
		}
	};

	tracked_forms.each(function() {
		$(this).data('initialForm', $(this).serialize());
	}).submit(function(e) {
		var formEl = this;
		var changed = false;
		tracked_forms.each(function() {
			if (this != formEl && $(this).data('initialForm') != $(this).serialize()) {
				changed = true;
				$(this).addClass('changed');
			} else {
				$(this).removeClass('changed');
			}
		});
    
		if (changed && !confirm('Another form has been changed.  If you leave this page, your changes won\'t be saved. Are you sure you want to leave?')) {
			e.preventDefault();
	    } else {
			$(window).unbind('beforeunload', catcher);
	    };
	});
	$(window).bind('beforeunload', catcher);
	
	$("form.no_submit").submit(function(e){
		e.preventDefault();
	});
	
	$("#menu").toggleboxes({
		navigation: true,
		icons: false
	});	
});
