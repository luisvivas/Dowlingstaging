(function($){
	$.markupFunctions = {
		// Return user specified markup:
		markupPercentage: function() {
			return parseFloat(this.markup_input.val());
		}, 
		
		// Calculates the markup multiplier for this line item:
		calcMarkupMultiplier: function() {
			return (this.markupPercentage() / 100) + 1;
		}
		
	};
	
	$.lineItem = function() {};
	$.lineItem.prototype = $.extend({}, $.markupFunctions, {
		// Sets any blank inputs to 0
		ensureUISet: function() {
			this.interactive_elements.each(function(){
				if($(this).val() == '') {
					$(this).val(0);
				}
			});
		},
		
		// Enables/disables all this line item's inputs. Called by chained selects to make sure nothing changes while stuff is propagating
		setUIState: function(state) { 
			if(state) {
				this.interactive_elements.removeAttr('disabled');
			} else {
				this.interactive_elements.attr('disabled', 'disabled');
			}
		},
		
		// Removes this line item from the quote item
		destroy: function(e) {
			e.preventDefault();
			this.$$.hide();
			this.destroy_input.val(1);
			this.$$.trigger('total_change');
		}
	});
	
	/** Product Line Item Object
	 * @constructor
	 */
	$.productLineItem = function(elem, parent) {
		if ( this === window ) { return new $.productLineItem(elem); }
		var $$ = $(elem);
		this.$$ = $$;
		if($$.obj() != null) {return true;} 		// return if the object has already been constructed
		$$.obj(this);								// init the object reference
		
		this.parent_quote_item			= parent;
		this.root_cat_select 			= $("select[name='product_root_categories']", $$); 		// root category select
		this.child_cat_select 			= $("select[name='product_child_categories']", $$);		// root category scoped child category chained select
		this.product_select 			= $("select[name='product_name']", $$);					// category scoped product chained select
		this.product_id_input			= $(".line_item_product_id", $$);						// hidden input holding product id
		this.product_size_select 		= $("select[name='product_size']", $$);					// product scoped product_size chained select
		this.product_size_id_input 		= $(".line_item_product_size_id", $$);					// hidden input holding the product_size id
		this.amount_needed_input 		= $(".line_item_amount_needed", $$);					// text input showing how many units (ft, sq ft, units) are required for the item
		this.amount_suffixes	 		= $(".amount_suffix", $$);
		
		this.dimension_selects			= $(".dimension_select", $$);							// jQuery of selects for dimension selects for types of products
		this.sheet_dimension_select 	= $("select[name='sheet_product_dimensions']", $$); 	// dimension select for products of type SheetProduct
		this.length_dimension_select	= $("select[name='length_product_dimensions']", $$);	// dimension select for products of type LengthProduct
		this.unit_dimension_select		= $("select[name='unit_product_dimensions']", $$);		// dimension select for products of type UnitProduct
		this.irregular_dimension_input	= $("input[name='irregular_dimension']", $$);			// irregular dimension input
		this.irregular_dimension_link	= $("a[href='#irregular_dimension']", $$);
		this.active_dimension_select 	= this.sheet_dimension_select;
		this.dimension_input			= $(".line_item_dimension", $$);
		
        this.previous_product_type		= "";

        this.finish_select 				= $(".line_item_finish", $$);
        this.grade_select 				= $(".line_item_grade", $$);                                         

		this.calc_order_quantity		= $(".calc_order", $$);									// js calc quantity of products in size & dimension to order to fufill amount needed
		this.real_order_quantity_input 	= $(".line_item_real_order_quantity", $$);				// user specified order quantity
		this.cost_per_pound_input		= $("input.line_item_cost_per_pound", $$);				// cost per pound of raw material of product
		
		this.unit_weight				= $(".unit_weight", $$);								// pounds per unit (ft, sq ft, unit) of product
		this.total_weight				= $(".total_weight", $$);								// pounds of product total
		this.unit_cost					= $(".unit_cost", $$);									// cost per unit (ft, sq ft, unit) of product
		this.piece_cost					= $(".piece_cost", $$);									// cost per piece (x ft in selected size) of product (based on weight per unit * cost per pound)
		this.markup_input				= $(".line_item_markup", $$);							// input for markup on this line item
		this.total_cost					= $(".total_cost", $$);									// total cost of line item
		this.total_cost_integer			= 0;
		
		this.destroy_input 				= $(".destroy_product_line_item", $$);					// hidden destroy product_line_item input
		this.destroy_link				= $("a.remove_product_line_item", $$);					// link to destroy product line item
		
		this.interactive_elements = this.root_cat_select
									.add(this.child_cat_select)
									.add(this.product_select)
									.add(this.product_size_select)
									.add(this.cost_per_pound_input)
									.add(this.amount_needed_input)
									.add(this.real_order_quantity_input)
									.add(this.dimension_selects)
									.add(this.grade_select)
									.add(this.finish_select)
									.add(this.markup_input);
		
		// Chained category and product selects
		// Set child selects disabled when root changes
		this.root_cat_select.change($.proxy(function() {
			this.setDefaultCostPerPound();
			this.setUIState(false);
		}, this));
		
		this.child_cat_select.chainedSelect({
			parent: this.root_cat_select,
			value: 'id',
			label: 'text',
			url: '/product_categories/subcategories',
			globalCache: true,
			cacheKey: 'sub_categories',
			initialLoad: false
		}).change($.proxy(function(e) {
			this.setUIState(false);
		}, this));
		
		this.product_select.chainedSelect({
			parent: this.child_cat_select,
			value: 'id',
			label: 'text',
			url: '/products/in_category',
			globalCache: true,
			cacheKey: 'product_name',
			initialLoad: false
		})
		.change($.proxy(this, "productChange"));
		
		this.product_size_select.chainedSelect({
			parent: this.product_select,
			value: 'id',
			label: 'text',
			url: '/products/sizes_for_product',
			globalCache: true,
			cacheKey: 'product_sizes',
			initialLoad: false
		})
		.change($.proxy(this, "productSizeChange"));
		
		if(this.cost_per_pound_input.val() == "" || this.cost_per_pound_input.asNumber() == 0) {
			this.setDefaultCostPerPound();
		}
		
		// Update the product specific stuff
		this.productChange(null, true);
		this.dimension_selects.change($.proxy(this, "dimensionChange"));
		this.dimension_selects.add(this.amount_needed_input).change($.proxy(this, 'updateQuantity'));
		this.irregular_dimension_input.change($.proxy(this, 'irregularDimensionChange'));
		this.irregular_dimension_link.click($.proxy(this, 'activateIrregularDimension'));
		this.markup_input.add(this.real_order_quantity_input).add(this.cost_per_pound_input).change($.proxy(this, 'updateTotal'));
		
		this.destroy_link.click($.proxy(this, 'destroy'));
		this.setUIState(true);	
		
		this.previous_product_type = this.productType();
		// Trigger the first update of the whole row
		this.productSizeChange();
		return this;
	};
	
	$.productLineItem.prototype = $.extend({}, $.lineItem.prototype, {
		// called when Product select changes
		productChange: function(e, first) {
			// Update ID
			this.product_id_input.val(this.product_select.val());
			
			
			// Dimension Selects:
			// All dimension info is stored in the dimension_input.
			// The active dimension select stores its value in there whenever changed.
			// If the dimension is irregular the irregular dimension textbox is shown.
			// If the product changes the dimension is set to the default if the product type is different.
			
			// Update dimension for unit products to properly initialize
			if(first && this.productType() == "UnitProduct") {
				this.dimension_input.val("1");
			}
			
			// Initialize / update the proper dimension select.
			this.setActiveDimension(first);
			
			// Trigger required changes.
			this.dimensionChange();
			
			// Update extras select			
			this.displayExtrasSelect();
			
			this.setUIState(false);
			
			// This sets it in advance for the next time this is called. This is weird because for the duration of the PLI's life,
			// this is actually set to the current product type, but isn't needed until after the product type changes, when it will
			// really be the previous one. Weird eh. It's because you can't capture the previous one after it has changed, cause its
			// the new one now! 
			this.previous_product_type = this.productType();
		},
		// Called when Product Size select changes
		productSizeChange: function(e) {
			this.product_size_id_input.val(this.product_size_select.val());
			this.unit_weight.html_highlight(this.unitWeight().toFixed(5)+" lbs / "+this.unitSuffix());
			this.updateQuantity(); // this starts the very first cascading update
		},
		// Called when any of the dimension inputs change
		dimensionChange: function() {
			if(this.active_dimension_select != this.irregular_dimension_input) {
				this.dimension_input.val($("option:selected", this.active_dimension_select).html());
			} else {
				this.dimension_input.val(this.active_dimension_select.val());
			}
		},
		activateIrregularDimension: function(e) {
			e.preventDefault();
			this.dimension_selects.hide();
			this.irregular_dimension_input.val(0);
			this.active_dimension_select = this.irregular_dimension_input;
			this.active_dimension_select.show();
			this.irregular_dimension_link.hide();
		},
		// Called when the irregular dimension changes to see if it is re-regular
		irregularDimensionChange: function(e) {
			this.dimensionChange();
			this.setActiveDimension(true);
		},
		unitSuffix: function() {
			return this.active_dimension_select.attr('data-suffix');
		},
		// Hides and shows the appropriate dimension selects for this product line item depending on the product type.
		setActiveDimension: function(initialize) {
			this.dimension_selects.hide();
			var type = this.productType();
			var actual_text = this.dimension_input.val();
			var default_selection = '1';
			
			if(type == 'SheetProduct') {
				this.active_dimension_select = this.sheet_dimension_select;
				default_selection = DEFAULT_SHEET_PRODUCT_DIMENSION;
			} else if (type == 'LengthProduct') {
				this.active_dimension_select = this.length_dimension_select;
				default_selection = DEFAULT_LENGTH_PRODUCT_DIMENSION; 
			} else if (type == 'UnitProduct') {
				this.active_dimension_select = this.unit_dimension_select;
				default_selection = '1';
			}
			
			this.amount_suffixes.html(this.unitSuffix());

			// If the product changed, initialize will be false and this shouldn't be checked
			// If the pli is being initialized, then this needs to be checked to see if the value is present in the select, and if not
			// show the irregular box.
			if(initialize) {
				if($("option", this.active_dimension_select).any(function(){ return $(this).text() == actual_text; })) {
					$("option[text='"+actual_text+"']", this.active_dimension_select).attr("selected", "selected");
					this.irregular_dimension_link.show();
				} else {
					this.active_dimension_select = this.irregular_dimension_input;
					this.irregular_dimension_link.hide();
				}
			} else {
				// Select the default if the type is different, keep the same value if the type is the same.
				if(type == this.previous_product_type) {
					$("option[text='"+actual_text+"']", this.active_dimension_select).attr("selected", "selected");
				} else {
					$("option[text='"+default_selection+"']", this.active_dimension_select).attr("selected", "selected");
				}
			}
			this.active_dimension_select.show();
		},
		productType: function() {
			return this.product_select.selected_attr('data-type');
		},
		productHasGrade: function() {
			return this.product_select.selected_attr('data-grade') === "true";
		},
		productHasFinish: function() {
			return this.product_select.selected_attr('data-finish') === "true";			
		},
		displayExtrasSelect: function() {
			if(this.productHasGrade()) {
				this.grade_select.show();
			} else {
				this.grade_select.hide();				
			}
			if(this.productHasFinish()) {
				this.finish_select.show();
			} else {
				this.finish_select.hide();				
			}
		},
		setDefaultCostPerPound: function () {
			this.cost_per_pound_input.val(this.root_cat_select.selected_attr('data-cost-per-pound')).trigger('blur');
		},
		// Weight per measurement (lbs per ft, lbs per sq ft ...)
		unitWeight: function() {
			return parseFloat(this.product_size_select.selected_attr('data-amount'));
		},	
		costPerPound: function() {
			return this.cost_per_pound_input.asNumber();
		},
		// Return user specified measurement of ft/sqft/units needed
		amountNeeded: function() {
			return parseFloat(this.amount_needed_input.val());
		},
		// Return user specified quantity of product in size & dimension combo to order
		orderQuantity: function() {
			return parseFloat(this.real_order_quantity_input.val());
		},
		// Return user selected dimension to order in for this product
		pieceDimension: function() {
			if(this.active_dimension_select != this.irregular_dimension_input) {
				return parseFloat(this.active_dimension_select.val());
			} else {
				// Irregular dimension select is active. Parse the dimension decimal from the entered text.
				var type = this.productType();
				if(type == 'SheetProduct') {
					// Parse ABxDC
					var strs = this.active_dimension_select.val().split('x', 2);
					if(strs.length == 2) {
						strs = $(strs).map(function() { return this.replace(/[^0-9]/, ""); });
						return parseFloat(strs[0]) * parseFloat(strs[1]);
					} else {
						return NaN;
					}
				} else if (type == 'LengthProduct' || type == 'UnitProduct') {
					return parseFloat(this.active_dimension_select.val());
				}
				return NaN;
			}
		},
		// Calculates how many size/dimension combos need to be ordered to satsify amount of ft/sqft/units needed
		calcOrderQuantity: function() {
			return (this.amountNeeded() / this.pieceDimension());
		},
		
		// Calculates the total weight of this product line item
    // Weight of each ft * the number of feet * the number of pieces
		calcTotalWeight: function() {
			return this.unitWeight() * this.pieceDimension() * this.orderQuantity();
		},
		
		// Calculates the cost of one unit of a product size ($ per ft, $ per sq ft)
		calcUnitCost: function() {
			return this.unitWeight() * this.costPerPound();
		},

		// Calculates the cost of one size/dimension combo for one product.
		calcPieceCost: function() {
			return this.calcUnitCost() * this.pieceDimension();
		},
		
		// Calculates the cost of the line item
		calcOrderCost: function() {
			return (this.orderQuantity() * this.calcPieceCost()) * this.calcMarkupMultiplier();
		},
		
		updateUnitCost: function(e) {
			this.unit_cost.html_highlight($.dollars(this.calcUnitCost()));
		},
		
		updatePieceCost: function(e) {
			this.piece_cost.html_highlight($.dollars(this.calcPieceCost()));
		},
		
		updateTotalWeight: function(e) {
			this.total_weight.html_highlight($.round_two(this.calcTotalWeight()) + " lbs");
		},
		
		// Called by a change in product or dimension
		// Updates the displayed calculated and real order quantities based upon any changes. Updates the total after
		updateQuantity: function(e) {
			this.ensureUISet();
			var amt = this.amountNeeded();
			this.amount_needed_input.val(amt);
			if(!(amt >= 0)) {
				this.amount_needed_input.val(0);
			}
			var calc = this.calcOrderQuantity();
			if(typeof calc == 'number' && !isNaN(calc)) {
				this.calc_order_quantity.html_highlight(calc.toFixed(5));
				this.real_order_quantity_input.val(calc.toFixed(5));
				this.updateTotal(e);
			} else {
				this.calc_order_quantity.html_highlight_error();
			}
		},
		
		// Called by change in real quantity, by change in size (change in unitcost), or by updateQuantity to propagate change to prices
		// Updates the displayed total based on the exisitng quantities
		updateTotal: function(e) {
			this.updateUnitCost(e);
			this.updatePieceCost(e);
			this.updateTotalWeight(e);
			this.total_cost_integer = this.calcOrderCost(); 
			if(typeof this.total_cost_integer == 'number' && !isNaN(this.total_cost_integer)) {
				this.total_cost.html_highlight($.dollars(this.total_cost_integer));
				this.$$.trigger('materials_total_change');
			} else {
				this.total_cost.html_highlight_error();
			}
			this.setUIState(true); // Needed for the first time, enables the UI because it starts disabled
		},
		
		// Generates an identifier for this product in this size/dimension combo
		pieceIdentifier: function() {
			this.ensureUISet();
			return this.product_id_input.val() + "_" + this.product_size_id_input.val() + "_" + this.active_dimension_select.val();
		},
		
		// Generates a summary object
		pieceSummary: function() {
			return {
				name: '<a href="/products/'+this.product_select.val()+'">' + $(':selected', this.product_select).text() + '</a>',
				size: $(':selected', this.product_size_select).text(),
				dimension: this.dimension_input.val() + " " + this.unitSuffix(),
				amount_needed: this.amount_needed_input.val(),
				quantity: this.real_order_quantity_input.val(),
				cost: this.total_cost_integer,
				item: this.parent_quote_item.name_input.val(),
				weight: this.calcTotalWeight()
			};
		}
	});
	
	$.fn.productLineItemize = function(parent) {
		return this.each(function() {
			new $.productLineItem(this, parent);
		});
	};
	
	/** Labour Line Item Object
	 * @constructor
	 */
	$.labourLineItem = function(elem, parent) {
		if ( this === window ) { return new $.quoteItem(elem); }
		var $$ = $(elem);
		this.$$ = $$;
		if($$.obj() != null) {return true;} 		// return if the object has already been constructed
		$$.obj(this);								// init the object reference
		
		this.parent_quote_item		= parent;
		this.workers_input	 		= $('.line_item_workers', $$);
		this.setup_time_input 		= $('.line_item_setup_time', $$);						// minutes
		this.run_time_input 		= $('.line_item_run_time', $$); 						// minutes
		this.hourly_rate_input 		= $('.line_item_hourly_rate', $$);
		this.calc_total_time		= $(".calc_time", $$);
		this.markup_input			= $(".line_item_markup", $$);							// input for markup on this line item
		this.total_cost				= $(".total_cost", $$);									// total cost of line item
		this.total_cost_integer		= 0;
		
		this.destroy_input 				= $(".destroy_labour_line_item", $$);					// hidden destroy labour_line_item input
		this.destroy_link				= $("a.remove_labour_line_item", $$);					// link to destroy labour line item
		
		this.hourly_rate_input.formatCurrency();
		
		this.interactive_elements = this.workers_input
									.add(this.setup_time_input)
									.add(this.run_time_input)
									.add(this.hourly_rate_input)
									.add(this.markup_input);
																
		this.interactive_elements.change($.proxy(this, 'updateTotal'));
		this.destroy_link.click($.proxy(this, 'destroy'));
		
		this.updateTotal();
		
		return this;
	};
	
	$.labourLineItem.prototype = $.extend({}, $.lineItem.prototype, {
		workers: function() {
			return parseFloat(this.workers_input.val());
		},
		hourlyRate: function() {
			return this.hourly_rate_input.asNumber();
		},
		calcWorkerHours: function() {
			return (parseFloat(this.run_time_input.val())) / 60;
		},
		calcTotalTime: function() {
			return (this.workers() * this.calcWorkerHours()) + (parseFloat(this.setup_time_input.val()) / 60);
		},
		calcTotalCost: function() {
			return (this.calcTotalTime() * this.hourlyRate()) * this.calcMarkupMultiplier();
		},
		updateQuantity: function(e) {
			this.calc_total_time.html_highlight($.round_two(this.calcTotalTime()));
		},
		// Called by a change in workers, setup time or run time
		// Updates the displayed total based on the exisitng quantities
		updateTotal: function(e) {
			this.setUIState(false);
			this.ensureUISet();
			this.updateQuantity(e);
			this.total_cost_integer = this.calcTotalCost();
			if(typeof this.total_cost_integer == 'number' && !isNaN(this.total_cost_integer)) {
				this.total_cost.html_highlight($.dollars(this.total_cost_integer));
				this.$$.trigger('labour_total_change');
			} else {
				this.total_cost.html_highlight_error();
			}
			this.setUIState(true);
			return true;
		},
		pieceIdentifier: function() {
			this.ensureUISet();
			return this.hourlyRate();
		},
		pieceSummary: function() {
			return {
				hourly_rate: this.hourlyRate(),
				hours: this.calcTotalTime(),
				cost: this.calcTotalCost(),
				item: this.parent_quote_item.name_input.val()
			};
		}
	});
	
	$.fn.labourLineItemize = function(parent) {
		return this.each(function() {
			new $.labourLineItem(this, parent);
		});
	};

	/** Custom Line Item Object
	 * @constructor
	 */	
	$.customLineItem = function(elem, parent) {
		if ( this === window ) { return new $.productLineItem(elem); }
		var $$ = $(elem);
		this.$$ = $$;
		if($$.obj() != null) {return true;} 		// return if the object has already been constructed
		$$.obj(this);								// init the object reference
		
		this.parent_quote_item			= parent;
		this.custom_name_input		 	= $(".line_item_name", $$);				// user specified order quantity
		this.real_order_quantity_input 	= $(".line_item_real_order_quantity", $$);				// user specified order quantity
		this.cost_per_piece_input		= $("input.line_item_cost_per_piece", $$);				// cost per pound of raw material of product
		
		this.markup_input				= $(".line_item_markup", $$);							// input for markup on this line item
		this.total_cost					= $(".total_cost", $$);									// total cost of line item
		
		this.destroy_input 				= $(".destroy_custom_line_item", $$);					// hidden destroy custom_line_item input
		this.destroy_link				= $("a.remove_custom_line_item", $$);					// link to destroy custom line item
		
		
		this.interactive_elements = this.custom_name_input.add(this.cost_per_piece_input).add(this.real_order_quantity_input).add(this.markup_input);
		this.interactive_elements.change($.proxy(this, 'updateTotal'));
		
		this.destroy_link.click($.proxy(this, 'destroy'));
		
		this.updateTotal();
		return this;
	};
	
	
	$.customLineItem.prototype = $.extend({}, $.lineItem.prototype, {
		customName: function() {
			return this.custom_name_input.val();
		},
		costPerPiece: function() {
			return this.cost_per_piece_input.asNumber();
		},
		orderQuantity: function() {
			return parseFloat(this.real_order_quantity_input.val());
		},
		calcTotalCost: function(e) {
			return (this.costPerPiece() * this.orderQuantity()) * this.calcMarkupMultiplier();
		},
		updateTotal: function(e) {
			this.setUIState(false);
			this.ensureUISet();
			this.total_cost_integer = this.calcTotalCost(); 
			if(typeof this.total_cost_integer == 'number' && !isNaN(this.total_cost_integer)) {
				this.total_cost.html_highlight($.dollars(this.total_cost_integer));
				this.$$.trigger('custom_total_change');				
			} else {
				this.total_cost.html_highlight_error();
			}
			this.setUIState(true);
		},
		pieceIdentifier: function() {
			this.ensureUISet();
			return this.custom_name_input.val() + this.cost_per_piece_input.val();
		},
		pieceSummary: function() {
			return {
				customName: this.customName(),
				quantity: this.orderQuantity(),
				costPerPiece: this.costPerPiece(),
				cost: this.calcTotalCost(),
				item: this.parent_quote_item.name_input.val()
			};
		}
	});
	
	$.fn.customLineItemize = function(parent) {
		return this.each(function() {
			new $.customLineItem(this, parent);
		});
	};
	
	/** Quote Item Object
	 * @constructor
	 */
	$.quoteItem = function(elem, index) {
		if ( this === window ) { return new $.quoteItem(elem); }
		var $$ = $(elem);
		this.$$ = $$;
		if($$.obj() != null) {return true;} 		// return if the object has already been constructed
		$$.obj(this);								// init the object reference
		
                                                                                
		this.edit_div 					= $('.edit_quote_item', $$);				// inner content div holding all the editable stuff
		this.deleted_div 				= $('.deleted_quote_item', $$);				// div outside edit div to hold undelete stuff
		this.destroy_input 				= $('input.destroy_quote_item', $$);		// hidden destroy text input
		this.undelete_link 				= $('a.undelete', $$);						// link to undelete quote item
		
		this.add_product_line_item_link = $('a.add_product_line_item', $$);			// link to add a product_line_item to this quote item
		this.product_line_items_table 	= $('table.product_line_items', $$);		// table to which a product_line_item might be added
		this.product_line_items			= this.productLineItems();					// existing line items
		this.product_template_div 		= $('#product_line_item_form_template');	// Template for adding new product line items
		
		this.add_labour_line_item_link 	= $('a.add_labour_line_item', $$);			// link to add a labour_line_item to this quote item
		this.labour_line_items			= this.labourLineItems();					// existing line items
		this.labour_line_items_table 	= $('table.labour_line_items', $$);			// table to which a labour_line_item might be added
		this.labour_template_div 		= $('#labour_line_item_form_template');		// Template for adding new product line items

		this.add_custom_line_item_link 	= $('a.add_custom_line_item', $$);			// link to add a custom_line_item to this quote item
		this.custom_line_items			= this.customLineItems();					// existing line items
		this.custom_line_items_table 	= $('table.custom_line_items', $$);			// table to which a custom_line_item might be added
		this.custom_template_div 		= $('#custom_line_item_form_template');		// Template for adding new custom line items
		
		this.products_subtotal 			= $('td.quote_item_products_subtotal', $$);			// Column in summary table
		this.labour_subtotal 			= $('td.quote_item_labour_subtotal', $$);			// Column in summary table
		this.custom_subtotal 			= $('td.quote_item_custom_subtotal', $$);			// Column in summary table
		this.hardware_markup_input	 	= $('table.summary .hardware_markup input', $$);	// Column in summary table
		this.markup_input	 			= $('table.summary .markup input', $$);				// Column in summary table
		this.item_subtotal	 			= $('td.quote_item_subtotal', $$);					// Column in summary table
		this.subtotal_cost_integer		= 0;
		this.item_total		 			= $('td.quote_item_total', $$);	// Column in summary table
		this.total_cost_integer			= 0;
		this.deleted					= false;									// Weather or not this quote item is presented as deleted
		this.name_input					= $('.header', $$);							// Input holding this quote item's name
		
		
		// Store the quote_item_index on the page if we're iterating through a bunch (the first call on page load)
		// This will ALREADY BE SET if this quote item is a template being quoteItemized, so the index isn't re-set
		if(typeof $$.data('quote_item_index') == 'undefined' || $$.data('quote_item_index') === '' || $$.data('quote_item_index') == null) {
			$$.data('quote_item_index', index);
		}
		
		$('.remove_quote_item', $$).click($.proxy(this, 'destroy'));

		$('.accordion', $$).accordion({
			autoHeight: false
		});
		
		this.name_input.change($.proxy(this, 'nameChange')).trigger('change');
		
		this.product_line_items.productLineItemize(this);
		this.labour_line_items.labourLineItemize(this);
		this.custom_line_items.customLineItemize(this);
		
		this.add_product_line_item_link.click($.proxy(this, 'addProductLineItem'));
		this.add_labour_line_item_link.click($.proxy(this, 'addLabourLineItem'));
		this.add_custom_line_item_link.click($.proxy(this, 'addCustomLineItem'));
		
		this.updateSummary();
		this.$$.bind("total_change materials_total_change labour_total_change custom_total_change", $.proxy(this, 'updateSummary'));
		this.markup_input.add(this.hardware_markup_input).change($.proxy(function() { this.$$.trigger('total_change'); },this));
		return this;
	};

	$.quoteItem.prototype = $.extend({}, $.markupFunctions, {
		// Return user specified markup:
		hardwareMarkupPercentage: function() {
			return parseFloat(this.hardware_markup_input.val());
		},
		
		// Calculates the markup multiplier for this line item:
		calcHardwareMarkupMultiplier: function() {
			return (this.hardwareMarkupPercentage() / 100) + 1;
		},
		productLineItems: function() {
			return $('.product.line_item', this.$$);
		},
		labourLineItems: function() {
			return $('.labour.line_item', this.$$);
		},
		customLineItems: function() {
			return $('.custom.line_item', this.$$);
		},
		nameChange: function(e) {
			this.undelete_link.html("Undelete "+this.name_input.val());
			this.$$.trigger('total_change');
		},
		destroy: function(e) {
			var after_change = function() {
				$(this).trigger('total_change');			
			};
			if(!this.deleted) {
				// Delete
				this.deleted = true;
				this.destroy_input.val(1);
				this.edit_div.slideUp(400, after_change);
				this.deleted_div.show();
			} else {
				// Undelete
				this.deleted = false;
				this.destroy_input.val(0);
				this.edit_div.slideDown(400, after_change);
				this.deleted_div.hide();
			}
		},

		addProductLineItem: function(e) {
			e.preventDefault();
			var template = this.product_template_div.children(0).clone(); // the first row of the template table is the template row.
			var line_item_index = $('tr', this.product_line_items_table).length;
			template = $(template.html().replace(/NEW_CHILD_RECORD/g, line_item_index).replace(/NEW_PARENT_RECORD/g, this.$$.data('quote_item_index')));
			template.appendTo(this.product_line_items_table);
			template.productLineItemize(this);
			this.product_line_items = this.productLineItems();
			this.$$.trigger('materials_total_change');
		},
		addLabourLineItem: function(e) {
			e.preventDefault();
			var template = this.labour_template_div.children(0).clone(); // the first row of the template table is the template row.
			var line_item_index = $('tr', this.labour_line_items_table).length;
			template = $(template.html().replace(/NEW_CHILD_RECORD/g, line_item_index).replace(/NEW_PARENT_RECORD/g, this.$$.data('quote_item_index')));
			template.appendTo(this.labour_line_items_table);
			template.labourLineItemize(this);
			this.labour_line_items = this.labourLineItems();
			this.$$.trigger('labour_total_change');
		},
		addCustomLineItem: function(e) {
			e.preventDefault();
			var template = this.custom_template_div.children(0).clone(); // the first row of the template table is the template row.
			var line_item_index = $('tr', this.custom_line_items_table).length;
			template = $(template.html().replace(/NEW_CHILD_RECORD/g, line_item_index).replace(/NEW_PARENT_RECORD/g, this.$$.data('quote_item_index')));
			template.appendTo(this.custom_line_items_table);
			template.customLineItemize(this);
			this.custom_line_items = this.customLineItems();
			this.$$.trigger('custom_total_change');
		},
		activeProductLineItems: function(e) {
			return this.product_line_items.select(function() {
				return $(this).is(':visible');								// only visible product line items
			});
		},
		activeLabourLineItems: function(e) {
			return this.labour_line_items.select(function() {
				return $(this).is(':visible');								// only visible labour line items
			});
		},
		activeCustomLineItems: function(e) {
			return this.custom_line_items.select(function() {
				return $(this).is(':visible');								// only visible custom line items
			});
		},
		updateSummary: function(e) {
			var products_total = this.activeProductLineItems().inject(0, function(sum){
				sum += $(this).obj().total_cost_integer;
				return sum;
			});
			var labour_total = this.activeLabourLineItems().inject(0, function(sum){
				sum += $(this).obj().total_cost_integer;
				return sum;
			});
			var custom_total = this.activeCustomLineItems().inject(0, function(sum){
				sum += $(this).obj().total_cost_integer;
				return sum;
			});
			
			this.products_subtotal.html_highlight($.dollars(products_total));
			this.labour_subtotal.html_highlight($.dollars(labour_total));
			this.custom_subtotal.html_highlight($.dollars(custom_total));
			
			this.subtotal_cost_integer = ((products_total + labour_total) * this.calcHardwareMarkupMultiplier()) + custom_total;
			this.item_subtotal.html_highlight($.dollars(this.subtotal_cost_integer));
			
			this.total_cost_integer = this.subtotal_cost_integer * this.calcMarkupMultiplier();
			this.item_total.html_highlight($.dollars(this.total_cost_integer));
		}
	});
	
	$.fn.quoteItemize = function() {
		return this.each(function(i) {
			new $.quoteItem(this, i); //pass in index so it can be stored for the index in dynamic addition of new quote items
		});	
	};
	
	/** Quote Form object
	 * @constructor
	 */
	$.quoteForm = function(elem) {
		if ( this === window ) { return new $.quoteForm(elem); }
		var $$ = $(elem);
		this.$$ = $$;
		if($$.obj() != null) { return true; } 		// return if the object has already been constructed
		$$.obj(this);								// init the object reference
		
		this.subtotal_cost_integer 			= 0;
		this.total_cost_integer				= 0;
		
		this.quote_item_template_div 		= $('#quote_item_form_template');
		this.quote_items_container 			= $('#quote_items_container');
		this.quote_items 					= this.quoteItems();
		this.add_quote_item_links 			= $('.add_quote_item', $$);
		this.materials_summary_table 		= $('#materials_summary');
		this.labour_summary_table	 		= $('#labour_summary');
		this.custom_summary_table	 		= $('#custom_summary');
		this.cost_summary_table				= $('#cost_summary');
		this.markup_input					= $('#quote_markup', this.cost_summary_table);
		this.total_cost_input				= $('#quote_total_cost');
		
		this.quote_items.quoteItemize();
		$('body')
		.live('total_change', $.proxy(this, 'updateSummaries'))
		.live('materials_total_change', $.proxy(this, 'updateMaterialsAndCostSummary'))
		.live('labour_total_change', $.proxy(this, 'updateLabourAndCostSummary'))
		.live('custom_total_change', $.proxy(this, 'updateCustomAndCostSummary'));
		
		this.add_quote_item_links.click($.proxy(this, 'addQuoteItem'));
		
		// Initialize Summary
		this.updateSummaries();
		
		this.total_cost_input.formatCurrency();
		this.total_cost_input.change($.proxy(this, 'totalCostInputChange'));
		this.markup_input.change($.proxy(this, 'updateTotalCost'));
		
		// Reinitialize initial form data, after all this JS has changed the form values to prevent bogus form changed messages
		$(elem).data('initialForm', $(elem).serialize());
		return this;
	};
	
	$.quoteForm.prototype = $.extend({}, $.markupFunctions, {
		quoteItems: function() {
			return $(".quote_item", this.quote_items_container);
		},
		activeQuoteItems: function() {
			return this.quote_items.select(function() {
				return !$(this).obj().deleted; 								// only visible quote items
			});
		},
		addQuoteItem: function(e) {
			e.preventDefault();
			var item_index = this.quote_items.length;
			var template = this.quote_item_template_div.clone();
			template = $(template.html().replace(/NEW_RECORD/g, item_index));
			template.appendTo(this.quote_items_container);
			template.data('quote_item_index', item_index);
			template.quoteItemize();
			this.quote_items = this.quoteItems();
			template.obj().name_input.focus();
		},
		markupChange: function(e) {
			this.total_cost_integer = this.total_cost_input.asNumber();
			var markup = (this.total_cost_integer / (this.subtotal_cost_integer || 1) - 1) * 100;
			this.markup_input.val(markup);
		},
		totalCostInputChange: function(e) {
			this.total_cost_integer = this.total_cost_input.asNumber();
			var markup = (this.total_cost_integer / (this.subtotal_cost_integer || 1) - 1) * 100;
			this.markup_input.val(markup);
			return true;
		},
		updateSummaries: function(e) {
			this.updateMaterialsSummary(e);
			this.updateLabourSummary(e);
			this.updateCustomSummary(e);
			this.updateCostSummary(e);
		},
		updateMaterialsAndCostSummary: function(e) {
			this.updateMaterialsSummary(e);
			this.updateCostSummary(e);
		},
		updateLabourAndCostSummary: function(e) {
			this.updateLabourSummary(e);
			this.updateCostSummary(e);
		},
		updateCustomAndCostSummary: function(e) {
			this.updateCustomSummary(e);
			this.updateCostSummary(e);
		},
		updateCostSummary: function(e) {
			var item_costs = this.activeQuoteItems().collect( function () {
				var obj = $(this).obj();
				return [obj.total_cost_integer, obj.name_input.val()];
			});
			this.subtotal_cost_integer = item_costs.inject(0, function(sum) {
				sum += this[0];
				return sum;
			});
			$('tr.item_cost', this.cost_summary_table).remove();
			var dest = $('tr:first', this.cost_summary_table);
			item_costs.each(function() {
				dest.after('<tr class="item_cost"><td>' + this[1] + "</td><td>" + $.dollars(this[0]) + "</td></tr>");
			});
			$('tr.subtotal td:eq(1)', this.cost_summary_table).html($.dollars(this.subtotal_cost_integer));
			this.updateTotalCost(e);
		},
		updateTotalCost: function(e) {
			this.total_cost_input.val(this.subtotal_cost_integer * this.calcMarkupMultiplier());	
		},
		updateMaterialsSummary: function(e) {
			// Update materials
			var product_line_items = this.activeQuoteItems().inject([], function(is) { 
					return $.merge(is, $(this).obj().activeProductLineItems().get()); // grab this quote items product line items
				}).collect( function() { 	
				 	return $(this).obj(); 										// extend the array and collect the product line item objects
				});
				
			var products_summary = $(product_line_items).inject({}, function(sum){
				var key = this.pieceIdentifier();
				var added = this.pieceSummary();
				if(typeof sum[key] == 'undefined') {
					// New material in summary
					sum[key] = added;
				} else {
					// Add quantity to summary
					sum[key].amount_needed 	+= added.amount_needed;
					sum[key].quantity 		+= parseFloat(added.quantity);
					sum[key].cost 			+= added.cost;
					sum[key].weight			+= added.weight;
					sum[key].item			+= ", " + added.item;
				}
				return sum;
			});
			
			var dest = this.materials_summary_table;
			$("tr:gt(0)", dest).remove();
			$.each(products_summary, function() {
				dest.append("<tr><td>" + [this.name, this.size, this.dimension, this.amount_needed, this.quantity, this.weight.toFixed(5)+" lbs", $.dollars(this.cost), this.item].join("</td><td>") + "</td></tr>");
			});
		},
		updateLabourSummary: function(e) {
			var labour_line_items = this.activeQuoteItems().inject([], function(is) { 
					return $.merge(is, $(this).obj().activeLabourLineItems().get()); // grab this quote items labour line items
				}).collect( function() { 	
				 	return $(this).obj(); 										// extend the array and collect the labour line item objects
				});
				
			var labour_summary = $(labour_line_items).inject({}, function(sum){
				var key = this.pieceIdentifier();
				var added = this.pieceSummary();
				if(typeof sum[key] == 'undefined') {
					// New material in summary
					sum[key] = added;
				} else {
					// Add quantity to summary
					sum[key].hours 	+= added.hours;
					sum[key].cost 	+= added.cost;
					sum[key].item	+= ", " + added.item;
				}
				return sum;
			});
			
			var dest = this.labour_summary_table;
			$("tr:gt(0)", dest).remove();
			$.each(labour_summary, function() {
				dest.append("<tr><td>" + [$.round_two(this.hours), $.dollars(this.hourly_rate), $.dollars(this.cost), this.item].join("</td><td>") + "</td></tr>");
			});
		},
		updateCustomSummary: function(e) {
			var custom_line_items = this.activeQuoteItems().inject([], function(is) { 
					return $.merge(is, $(this).obj().activeCustomLineItems().get()); // grab this quote items labour line items
				}).collect( function() { 	
				 	return $(this).obj(); 										// extend the array and collect the labour line item objects
				});
				
			var custom_summary = $(custom_line_items).inject({}, function(sum){
				var key = this.pieceIdentifier();
				var added = this.pieceSummary();
				if(typeof sum[key] == 'undefined') {
					// New material in summary
					sum[key] = added;
				} else {
					// Add quantity to summary
					sum[key].quantity 	+= added.quantity;
					sum[key].cost 		+= added.cost;
					sum[key].item		+= ", " + added.item;
				}
				return sum;
			});
			
			var dest = this.custom_summary_table;
			$("tr:gt(0)", dest).remove();
			$.each(custom_summary, function() {
				dest.append("<tr><td>" + [this.customName, this.quantity, $.dollars(this.costPerPiece), $.dollars(this.cost), this.item].join("</td><td>") + "</td></tr>");
			});
		}
	});
	
	$.fn.quoteFormize = function() {
		return this.each(function() {
			new $.quoteForm(this);
		});
	};

	$(document).ready(function() {
		$('form.in_play').quoteFormize();
		var fix_contact = function() {
			$('#quote_contact_id').val("");
			$('#auto_contact_name').val("");
		};
		$('#auto_business_name').change(fix_contact).result(fix_contact);
		$('.accordion').accordion({
			autoHeight: false
		});
		
	});
	
})(jQuery);
