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
    end

    def read_data
      file = File.open(file_path)
      file_data = JSON.parse(file.read).deep_symbolize_keys
      return file_data unless @c.json_scope
      @c.json_scope.call(file_data)
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
      self.class.permit_attributes.each { |attribute| object[attribute] = instance.send(attribute) }
      return true if write_data(data)
      false
    end

    def write_data(data)
    end

    private

    def permitted_attributes
      return nil unless @c.permit_attributes
      @c.permit_attributes
    end

    def attribute_permitted?(attribute)
      return false unless permitted_attributes.include?(attribute)
      true
    end

    def file_path
      Rails.root.join(file_name.unshift('data'))
    end

    def file_name
      [@c.file_name] || @c.to_s.split('::').map(&:underscore)
    end
  end
end
