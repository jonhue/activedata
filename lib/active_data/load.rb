require 'active_support'

module ActiveData
  class Load
    def initialize(classes)
      @classes = classes
    end

    def perform
      @classes&.each do |c|
        c.all = Dataset.new(c).perform
      end
    end

    class Dataset
      def initialize(c)
        @c = c
      end

      def perform
        file = File.open(file_path)
        data = parse_data
        create_instances(data)
      end

      private

      def create_instances(data)
        instances = []
        data.map do |object|
          object.each { |k, v| delete(k) unless attribute_permitted?(k) }
          instances << @c.new(object)
        end
      end

      def parse_data
        file_data = JSON.parse(file.read).deep_symbolize_keys
        return file_data unless @c.json_scope
        @c.json_scope.call(file_data)
      end

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
end
