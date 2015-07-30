require 'ostruct'
require "json"

class JsonStruct < OpenStruct
  def initialize(hash=nil)

    @table = {}
    @hash_table = {}

    if hash
      recurse = Proc.new do |item|
        values = []

        item.each do |val|
          if val.is_a?(Hash)
            values.push(self.class.new(val))
          elsif val.is_a?(Array)
            values.push(recurse.call(val))
          else
            values.push(val)
          end
        end

        item.clear
        item.push(*values)

        item
      end

      hash.each do |k,v|

        if v.is_a?(Array)
          recurse.call(v)
        end

        @table[k.to_sym] = (v.is_a?(Hash) ? self.class.new(v) : v)
        @hash_table[k.to_sym] = v
        new_ostruct_member(k)

      end
    end
  end

  def to_h
    op = {}

    @table.each_pair do |key, value|
      if value.is_a?(Array)
        op[key] = value.map do |item|
          if item.is_a?(self.class)
            item.to_h
          else
            item
          end
        end
      elsif value.is_a?(self.class)
        op[key] = value.to_h
      else
        op[key] = value
      end
    end
    op
  end

  def to_json
    JSON.dump(to_h)
  end

end