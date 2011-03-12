Settings.defaults[:application_name] = "DSIT"
Settings.defaults[:company_name] = "Dowling Metals and Fabrication"
Settings.defaults[:labour_hourly_rate] = 55           # hourly rate for labour line items
Settings.defaults[:product_markup] = 25               # % markup applied to each product line item
Settings.defaults[:custom_markup] = 25               # % markup applied to each custom line item
Settings.defaults[:labour_markup] = 10                # % markup applied to each labour line item
Settings.defaults[:quote_item_hardware_markup] = 5    # markup for each item's hardware
Settings.defaults[:quote_item_markup] = 10            # markup for each item overall
Settings.defaults[:quote_markup] = 0                    # % markup rate on each quote
Settings.defaults[:administrator_email] = "harry@skylightlabs.ca"

Settings.defaults[:google_domain] = "skylightlabs.ca"
Settings.defaults[:calendar_id] = "skylightlabs.ca_po7ab37dmq08sr8nimaf42j6m8@group.calendar.google.com"
Settings.defaults[:generic_calendar_url] = "http://www.google.com/calendar/render"

Settings.defaults[:length_product_dimensions] = [12, 20, 24]
Settings.defaults[:default_length_product_dimension] = Settings.defaults[:length_product_dimensions].first

Settings.defaults[:sheet_product_dimensions] = ["3x8", "3x10", "4x8", "4x10", "4x12", "5x8", "5x10"]
Settings.defaults[:default_sheet_product_dimension] = Settings.defaults[:sheet_product_dimensions].first

Settings.defaults[:available_grades] = ["304", "309", "310", "316", "321", "430", "3CR12"]
Settings.defaults[:available_finishes] = ["No. 0: Hot rolled, annealed, thicker plates",
                                          "No. 1: Hot rolled, annealed and passivated",
                                          "No. 2D: Cold rolled, annealed, pickled and passivated",
                                          "No. 2B: Same as above with additional pass-through highly polished rollers",
                                          "No. 2BA: Bright annealed (BA or 2R) same as above then bright annealed under oxygen-free atmospheric conditions",
                                          "No. 3: Coarse abrasive finish applied mechanically",
                                          "No. 4: Brushed finish",
                                          "No. 5: Satin finish",
                                          "No. 6: Matte finish",
                                          "No. 7: Reflective finish",
                                          "No. 8: Mirror finish",
                                          "No. 9: Bead blast finish",
                                          "No. 10: Heat colored finish-wide range of electropolished & heat colored surfaces"]

