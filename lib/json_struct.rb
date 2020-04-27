require "ostruct"
require "json"

class JsonStruct < OpenStruct
  def initialize(hash = nil)
    @table = {}
    @hash_table = {}

    if hash
      recurse = proc { |item|
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
      }

      hash.each do |k, v|
        if v.is_a?(Array)
          recurse.call(v)
        end

        @table[k.to_sym] = (v.is_a?(Hash) ? self.class.new(v) : v)
        @hash_table[k.to_sym] = v
        new_ostruct_member!(k)
      end
    end
  end

  def to_h
    op = {}

    @table.each_pair do |key, value|
      op[key] = if value.is_a?(Array)
        value.map do |item|
          if item.is_a?(self.class)
            item.to_h
          else
            item
          end
        end
      elsif value.is_a?(self.class)
        value.to_h
      else
        value
      end
    end
    op
  end

  def as_json(*args)
    to_h
  end

  def to_json
    JSON.dump(to_h)
  end
end
