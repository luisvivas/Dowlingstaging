module Gridify
  class Grid
    
    attr_accessor :search_rules,        # current search/filter rules, as hash
                  :search_rules_op      # :and, :or 
    
    # finds records based on request params
    # e.g. params from jqGrid
    #   :_search      do search (true/false)  ["false"]
    #   :sidx         sort index (column to search on)  [""]
    #   :sord         sort direction (desc/asc)  ["asc"]
    #   :nd           ?
    #   :rows         number of items to get   ["20"]
    #   :page         page number (starts at 1) ["1"]
      
    def update_from_params( params )
      params = params.symbolize_keys
      self.search_rules = []
      params_to_rules params
      self.sort_by       = params[:sidx] if params[:sidx]
      self.sort_order    = params[:sord] if params[:sord]
      self.current_page  = params[:page].to_i if params[:page]
      self.rows_per_page = params[:rows].to_i if params[:rows]
    end

    # return find args (scope) for current settings
    def current_scope
      cond = rules_to_conditions
      relation = resource.classify.constantize.scoped
      relation = relation.where(cond) unless cond.blank?
      if sort_by.present? && col = columns_hash[sort_by]
        if case_sensitive || !([:string, :text].include?(col.value_type))
          relation = relation.order("#{sort_by} #{sort_order}")
        else
          relation = relation.order("upper(#{sort_by}) #{sort_order}")
        end
      end
      if rows_per_page.present? && rows_per_page > 0
        relation = relation.limit(rows_per_page)
        offset_amt = (current_page.to_i-1) * rows_per_page if current_page.present?
        relation = relation.offset(offset_amt) if offset_amt && offset_amt > 0
      end      
      relation
    end
    
    def find( params )
      update_from_params params
      current_scope
    end
    
    def encode_records( records, total_count=nil )
      klass = resource.classify.constantize
      total_count ||= klass.count
      total_pages = total_count / self.rows_per_page + 1
      #TODO: :only => [attributes], :methods => [virtual attributes]
      
      case data_type
      when :xml
        except = []
        procs = self.columns.inject([]) do |procs, column|
          if column.proc
            procs << Proc.new { |options, record| options[:builder].tag!(column.name, column.proc.call(record)) }
            except << column.name.intern
          end
          procs
        end
        
        xml = records.to_xml( :skip_types => true, :dasherize => false, :procs => procs, :except => except, :root => self.resource) do |xml|
          if rows_per_page > 0
            xml.page          current_page
            xml.total_pages   total_pages
            xml.total_records total_count
          end
        end
        
      when :json
        data = { resource => records }
        if rows_per_page > 0       
          data.merge!( 
            :page => current_page, 
            :total_pages => total_pages, 
            :total_records => total_count 
          )
        end
        
        save = ActiveRecord::Base.include_root_in_json
        ActiveRecord::Base.include_root_in_json = false
        json =  ActiveSupport::JSON.encode(data)
        ActiveRecord::Base.include_root_in_json = save
        json

      #others...
      else #nop ?
        records.to_s
      end
    end
    
    def find_and_encode( params )
      encode_records( find( params ) )
    end
    
    # grid doesnt nest attributes inside the resource
    # could change this behavior in jqGrid, see grid.postext.js ?
    #   http://www.trirand.com/jqgridwiki/doku.php?id=wiki:post_data_module
    #   
    def member_params( params )
      params.inject({}) {|h, (name, value)| h[name] = value if columns_hash[name]; h }
    end
    
    
    protected
    
    OPS = { 'eq' => '=', 'lt' => '<', 'le' => '<=', 'gt' => '>', 'ge' => '>=', 'ne' => '!=' } 
    #['eq','ne','lt','le','gt','ge',
    # 'bw','bn','in','ni','ew','en','cn','nc']
    #['equal','not equal', 'less', 'less or equal','greater','greater or equal', 
    # 'begins with','does not begin with','is in','is not in','ends with','does not end with','contains','does not contain']

    OPS_PATTERN = { 
      'bw' => '?%', 
      'bn' => '?%', 
      # 'in'
      # 'ni'
      'ew' => '%?', 
      'en' => '%?', 
      'cn' => '%?%', 
      'nc' => '%?%', 
    }
    
    STRING_OPS = { 
      'bw' => 'ILIKE', 
      'bn' => 'NOT ILIKE', 
      'ew' => 'ILIKE', 
      'en' => 'NOT ILIKE', 
      'cn' => 'ILIKE', 
      'nc' => 'NOT ILIKE', 
    }
    
    
    # params[:filters] => {"groupOp"=>"AND", 
    #              "rules"=>[{"data"=>"b", "op"=>"ge", "field"=>"title"}, {"data"=>"f", "op"=>"le", "field"=>"title"}] }    
    def params_to_rules( params )
      #debugger
      if params[:_search]=='true' || params[:_search]==true
        if params[:filters]
          # advanced search         
          filters = ActiveSupport::JSON.decode( params[:filters] )
          self.search_rules = filters['rules']
          self.search_rules_op = filters['groupOp']
        elsif params[:searchField]
          # simple search
          self.search_rules = [{ "field" => params[:searchField], "op" => params[:searchOper], "data" => params[:searchString]}]
        else
          # toolbar search
          self.search_rules = []
          self.search_rules_op = :and
          columns.each do |col|  
            name = col.name
            data = params[name.to_sym]        
            self.search_rules << { "field" => col.search_field, "op" => "cn", "data" => data } if data
          end
        end
      end
      search_rules
    end
    
    def rules_to_conditions
      # note: ignoring case_sensitive as an option, ActiveRecord find is insensitive by default (have to model the db to let it be case sensitive?)
      return nil if search_rules.blank?
      cond = nil
      expr = ''
      vals = []
      search_rules.each do |rule|
        expr << " #{search_rules_op} " unless expr.blank?
        if op = OPS[rule['op']]
          expr << "#{rule['field']} #{op} ?"
          vals << rule['data']
        elsif op = STRING_OPS[rule['op']]
          expr << "#{rule['field']} #{op} ?"
          vals << OPS_PATTERN[rule['op']].gsub('?', rule['data'])
        end
      end
      cond = [ expr ] + vals      
    end


  end
end


# # If you need to display error messages
# err = ""
# if user
#   user.errors.entries.each do |error|
#     err << "<strong>#{error[0]}</strong> : #{error[1]}<br/>"
#   end
# end
# 
# render :text => "#{err}"


#	{ :add => true, :edit => true, :inline_edit => false, :delete => true, :edit_url => "/users/post_data", :error_handler => "after_submit" }
