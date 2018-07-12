# frozen_string_literal: true

require 'json'
require 'active_support'

module ActiveData
  class Dataset
    def initialize(klass)
      @klass = klass
    end

    def load
      load_data(read_data)
    end

    def load_data(data)
      data.each_with_index do |object, index|
        object.each do |k, v|
          object.delete(k) unless !v.nil? && attribute_permitted?(k)
        end
        object[:id] = index + 1 unless object.key?(:id)
        @klass.new(object)
      end
    end

    def read_data
      File.open(file_path, 'w') { |f| f.write('[]') } unless file_path.file?
      file = File.open(file_path)
      file_data = JSON.parse(file.read).map(&:deep_symbolize_keys)
      return file_data unless @klass.active_data_config[:json_scope]
      @klass.active_data_config[:json_scope].call(file_data)
    end

    def write(instance)
      data = read_data
      if instance.id.nil?
        object = {}
        if instance.class.explicit_ids?
          instance.id = object[:id] = data.length + 1
        end
        data.push(object)
      elsif instance.class.explicit_ids?
        object = data.select { |obj| obj[:id] == instance.id }.first
      else
        object = data[instance.id - 1]
      end
      permitted_attributes.each do |attribute|
        if instance.class.explicit_nulls?
          object[attribute] = instance.send(attribute)
        else
          unless instance.send(attribute).nil?
            object[attribute] = instance.send(attribute)
          end
        end
      end
      write_data(data)
    end

    def remove(instance)
      return false if instance.id.nil?
      data = read_data
      if instance.class.explicit_ids?
        data.select { |obj| obj[:id] == instance.id }.first = nil
      else
        data[instance.id - 1] = nil
      end
      write_data(data.compact)
    end

    def write_data(data)
      return false if @klass.prohibit_writes?
      File.open(file_path, 'w') do |f|
        f.write(data.to_json)
      end
      true
    end

    private

    def permitted_attributes
      return [] unless @klass.active_data_config[:permit_attributes]
      @klass.active_data_config[:permit_attributes]
    end

    def attribute_permitted?(attribute)
      unless attribute == :id || permitted_attributes.include?(attribute)
        return false
      end
      true
    end

    def file_path
      Rails.root.join(*file_name.unshift('data'))
    end

    def file_name
      unless @klass.active_data_config[:file_name].nil?
        return [@klass.active_data_config[:file_name] + '.json']
      end
      (@klass.to_s + '.json').split('::').map(&:underscore)
    end
  end
end
