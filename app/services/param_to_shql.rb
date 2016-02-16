#
# ParamToShql
# 
# Methods concerning the parsing of filters (using common UI idioms such as 
# checkboxes) into SHQL, the SHiftQueryLanguage understandable by the API.
#
# e.g. 
#   {"meta.colour"=>{"blue"=>"on", "red"=>"on"},"price"=>{"gt"=>"", "lt"=>""}}
# would become
#   "or" => [{"meta.colour"=>{"eq"=>"blue"}},{"meta.colour"=>{"eq"=>"red"}}...]
#
# TODO: More documentation
#
module FlexCommerce
  class ParamToShql

    #
    # initialize
    #
    def initialize(filter_param)
      @filter_param = filter_param
    end
    

    # 
    # call
    #
    def call
      return {} unless @filter_param

      facet_filters = []
      @filter_param.each do |label,facet|
        if facet.keys.include?("gt") || facet.keys.include?("lt")
          range_filter =  range_param_to_shql(label, facet)
          facet_filters << range_filter if !(range_filter == "" || range_filter == nil)
        else
          facet.keys.each do |value| 
            facet_filters << { label => { "eq" => value } }
          end
        end
      end
      return { "or" => facet_filters }
    end

    private


    #
    # range_param_to_shql
    # 
    # e.g. "variants.price"=>{"gt"=>10, "lt"=>20}
    #
    # name:           e.g. variants.price
    # attrs:          e.g. { "gt" => 10 }
    #
    def range_param_to_shql(name, attrs)
      range_filter = { "and" => [] }

      attrs.each do |op,value| 
        next if (value == "" || value == nil)
        range_filter["and"] << { name => { op => value } }
      end
      if range_filter["and"].any?
        range_filter
      else
        nil
      end
    end
  end
end
