#
# ParamToShql
#
# Service for converting UI-based filters (using common UI idioms such as
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
      @filter_param.each do |label, facet|
        facet_filter = []
        if (facet.keys & ["lt", "lte", "gt", "gte"]).any?
          range_filter = range_param_to_shql(label, facet)
          facet_filter << range_filter unless range_filter == "" || range_filter.nil?
        else
          facet.keys.each do |value|
            facet_filter << {label => {"eq" => value}}
          end
        end
        facet_filters << {"or" => facet_filter}
      end
      facet_filters.count == 1 ? facet_filters.first : {"and" => facet_filters}
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
      range_filter = {"and" => []}

      attrs.each do |op, value|
        next if value == "" || value.nil?
        range_filter["and"] << {name => {op => value}}
      end
      if range_filter["and"].any?
        range_filter
      end
    end
  end
end
