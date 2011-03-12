/*
 Transform a table to a jqGrid.
 Harry Brundage
*/

(function($){
 $.fn.jqGridize = function(options) {

	var defaults = {
		rowNum: 10,
		scroll: false,
		columnOptions: {
			align: 'center',
			width: 151
		}
	};
	options = $.extend(defaults, options);
		
	return this.each(function() {
		var table = $(this);
		table.width("99%");
		var colModel = [];
		var colNames = [];
		
		$('th', table).each(function() {
			var columnName = $.trim($.jgrid.stripHtml($(this).html()));
			var th = $(this);
			var width = (th.width() || defaults.columnOptions.width);
			var column = {
				name: columnName,
				index: th.attr("id") || th.attr("data-column-id") || columnName.split(' ').join('_'),
				width: width
			};
			// Add the column name, index, and width
			console.log(column);
			// Parse out any column data attributes, use defaults if not found and they exist
			$.each(['name', 'index', 'align', 'editable', 'hidden', 'resizable', 'search', 'sortable', 'sorttype'], function(index, key) {
				var value = table.attr('data-jqg-'+key);
				if(value) {
					column[key] = value;
				} else {
					if(typeof(defaults.columnOptions[key]) != 'undefined') {
						column[key] = defaults.columnOptions[key];
					}
				}
			});
			
			colModel.push(column);
			colNames.push(columnName);
		});
		
		var data = [];
		$('tbody > tr', table).each(function() {
			var row = {};
			var rowPos = 0;
			$('td', $(this)).each(function() {
				//For each row, set the data attribute
				row[colModel[rowPos].name] = $.trim($(this).html());
				rowPos++;
			});
			if(rowPos > 0) { data.push(row); }
		});
	
		var pager = $('<div id="pager" class="scroll" style="text-align:center;"></div>').insertAfter(table);
		
		var gridOptions = {
			colNames: colNames,
			colModel: colModel,
			pager: $("#pager"),
			width: table.width()
		};
		
		$.each(['width', 'datatype', 'url', 'caption', 'sortname', 'sortorder', 'page', 'rowNum', 'records', 'caption', 'scroll'], function(index, key) {
			var value = table.attr('data-jqg-'+key);
			if(value) {
				gridOptions[key] = value;
			} else {
				if(typeof(defaults[key]) != 'undefined') {
					gridOptions[key] = defaults[key];
				}
			}
		});
			
		// Clear the original HTML table
		table.empty();
		
		// Mark it as jqGrid
		if(gridOptions.scroll) {table.addClass("scroll");}
		console.log(gridOptions);
		table.jqGrid(gridOptions);
		// Add Data
		$.each(data, function(index, row) {
			table.jqGrid("addRowData", index+1, row);
		});
	});
 };
})(jQuery);