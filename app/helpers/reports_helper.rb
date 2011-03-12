module ReportsHelper
  def work_order_autocomplete
		text_field_tag :auto_work_order_name, "",
						:class						=> "autocomplete", 
						:autocomplete_url	=> autocomplete_for_work_order_name_work_orders_path, 
						:data_update      => '#work_order_id',
						:data_must_match  => 'false',
						:title            => "Enter the name or number of a work order to generate a report about it."
  end
  def quote_autocomplete
		text_field_tag :auto_quote_name, "",
						:class						=> "autocomplete", 
						:autocomplete_url	=> autocomplete_for_quote_job_name_quotes_path, 
						:data_update      => '#quote_id',
						:data_must_match  => 'false',
						:title            => "Enter the name or number of a quote to generate a report about it."
  end
  
  def time_sheet_rows(infos)
    rows = infos[:work_orders].inject(0) do |acc,(wo_name, wo)|
      wo.each do |qi, reports|
        acc += reports.length
      end
      acc
    end
    rows += time_sheet_extra_rows(infos)
    rows
  end
  
  def time_sheet_extra_rows(info)
    info[:reports].inject(0) do |acc, report|
      acc += 1 if report.extra_hours > 0.0
      acc
    end
  end
  
  def time_sheet_work_order_rows(items)
    items.inject(0) do |acc, (k, v)|
      acc += v.length
      acc
    end
  end
end
