jQuery(function($) {
	var go = function(pre, suf, element, params) {
		var id = $(element).val();
		if(!(parseInt(id) > 0)) {
			alert("Please select something to view.");
		} else {
			var str = "/" + [pre,id,suf].join("/");
			if(params) {
				str += "?" + $.param(params);
			}
			window.location = str;
		}
	};
	$("#prof_go").click(function(e) {
		go("reports", "profitability", "#work_order_id");
	});
	$("#printable_go").click(function(e) {
		go("quotes", "printable", "#quote_id");
	});
	$("#time_sheet_go").click(function(e) {
		var params = {
			start_date: $("#time_sheet_start_date").val(),
			end_date:  $("#time_sheet_end_date").val()
		};
		go("reports", "time_sheet", "#time_sheet_user_id", params);
	});
});