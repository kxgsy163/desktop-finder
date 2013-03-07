require "desktop/finder/version"

module Desktop
  module Finder
      def Finder.test
        puts '-----------test finder gem--------------'
      end

      def Finder.create(params, simple=false, form=nil)
        puts '---------------finder create--------------------'
        record = Kernel.const_get(params[:controller].classify).new.attributes
        options = record.each_key.collect{|key| 
          value = []
          type = "text"
          if key.include?("_id")
            begin
              value = Kernel.const_get(key.to_s.classify.sub('Id', '')).all.collect{|p|[p.id, p.name]}
            rescue
              next
            end
            type = "select"
          end
          {:type=>type, :name=>key, :label=>key, :value=>value}
        }
        #options = options || [{:type=>"text", :name=>"title", :label=>t('Title'), :value=>''},{:type=>'select', :name=>'issue_type_id', :label=>t('Issue Type'), :value=>IssueType.all}]
        options = options || {}
        if options.empty? 
          return ''
        end
        html = '<a href="#" class="pull-right" onclick="$(\'#J_searchWhere\').slideToggle();">.</a>'
        if form
          html << "<form method='get'>"
        end
        first = options.first
        search_params = params[:search_where] || {}
        html << '<div class="search-where" id="J_searchWhere" style="'+ (search_params ? '' : 'display:none;') + '">'
        select_option = []
        options.each do |option|
          next if option.blank?
          case simple
          when false
            html << Desktop::Finder.label_tag("", option[:label], {:class=>"search-label"})
          else
            select_option = select_option.push([option[:name], option[:label]])
          end
          html << '<div class="seach-value">'
          case option[:type]
          when 'select'
            html << Desktop::Finder.select_tag(option[:name], option[:value], search_params[option[:name]])
          else
            html << Desktop::Finder.text_field_tag(option[:name], search_params[option[:name]], {:class=>"span2"})
          end
          html << '</div>'
        end
        html << Desktop::Finder.submit_tag('Search', {:class=>"btn"})
        html << '</div>'

        if form
          html << '</form>'
        end

        html.html_safe
      end

      def Finder.where(params)
        #where = params.reject{|p,v| p=='controller' or p=='action' or p=='search' or p=='commit' or v.empty?}
        if !params.has_key?("search_where")
          return {}
        end
        where = params[:search_where].reject{|p,v| v.empty?}
        where
      end

      def Finder.submit_tag(label, o)
        "<input type=\"button\" value='#{label}' class='#{o[:class]}' onclick=\"$(this).parents('form:first').submit();\" />"
      end

      def Finder.text_field_tag(name, value, o)
        "<input type='text' name='search_where[#{name}]' value='#{value}' class='#{o[:class]}' />"
      end

      def Finder.select_tag(name, o, value)
        s = "<select name=\"search_where[#{name}]\">"
        s << "<option value=''></option>"
        o.each do|p|
          s << '<option value="' << p.fetch(0).to_s << '" ' << (p.fetch(0).to_s==value.to_s ? 'selected="selected"' : '') << '>' << (p.many? ? p.fetch(1).to_s : p.fetch(0).to_s) << '</option>'
        end
        s << '</select>'
        s
      end

      def Finder.label_tag(id, label, o)
         "<label class='#{o[:class]}'>#{label}</label>"
      end

  end
end
