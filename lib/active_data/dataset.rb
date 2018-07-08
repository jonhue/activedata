require 'json'
require 'active_support'

module ActiveData
  class Dataset
    def initialize(c)
      @c = c
    end

    def load
      load_data(read_data)
    end

    def load_data(data)
      instances = []
      data.each_with_index do |object, index|
        object.each { |k, v| delete(k) unless attribute_permitted?(k) }
        object[:id] = index unless object.key?(:id)
        instances << @c.new(object)
      end
      instances
    end

    def read_data
      File.open(file_path, 'w') { |f| f.write('[]') } unless file_path.file?
      file = File.open(file_path)
      file_data = JSON.parse(file.read).map(&:deep_symbolize_keys)
      return file_data unless @c.active_data_config[:json_scope]
      @c.active_data_config[:json_scope].call(file_data)
    end

    def write(instance)
      data = read_data
      if instance.id.nil?
        object = {}
        object[:id] = data.length if instance.class.explicit_ids?
        data.push(object)
      else
        if instance.class.explicit_ids?
          object = data.select { |obj| obj[:id] == instance.id }.first
        else
          object = data[instance.id - 1]
        end
      end
      self.class.active_data_config[:permit_attributes].each { |attribute| object[attribute] = instance.send(attribute) }
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
      File.open(file_path, 'w') do |f|
        f.write(data.to_json)
      end
      true
    end

    private

    def permitted_attributes
      return [] unless @c.active_data_config[:permit_attributes]
      @c.active_data_config[:permit_attributes]
    end

    def attribute_permitted?(attribute)
      return false unless attribute == :id || permitted_attributes.include?(attribute)
      true
    end

    def file_path
      Rails.root.join(*file_name.unshift('data'))
    end

    def file_name
      return [@c.active_data_config[:file_name] + '.json'] unless @c.active_data_config[:file_name].nil?
      (@c.to_s + '.json').split('::').map(&:underscore)
    end
  end
end
