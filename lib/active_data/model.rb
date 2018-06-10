require 'active_support'
require 'active_model'

module ActiveData
  class Model
    include ActiveSupport::Concern

    included do
      include ActiveModel::Model

      cattr_accessor :all, :dataset
      attr_accessor :id

      include ClassMethods
    end

    module ClassMethods
      def create(options = {})
        instance = self.class.new
        options.each { |k, v| instance.send(k) = v }
        instance if instance.save
      end

      def dataset
        @@dataset ||= Dataset.new(self.class)
      end

      def explicit_ids?
        self.explicit_ids || self.explicit_ids.nil?
      end
    end

    def save
      valid? ? self.class.dataset.write(self) : false
    end

    def update(options = {})
      fallback = self
      options.each { |k, v| send(k) = v }
      save ? self : fallback
    end

    def update_attributes(options = {})
      update(options)
    end

    def update_attribute(attribute, value)
      update("#{attribute}": value)
    end

    def where(options = {})
      select do |instance|
        if options.is_a?(Hash)
          options.each { |k, v| instance.send(k) == v }
        else
          a, operator, b = options.split(' ').map { |str| str.is_integer? ? str.to_i : instance.send(str) }
          a.send(operator, b)
        end
      end
    end

    def find_by(options = {})
      where(options).first
    end

    def find(param)
      param.is_a?(Array) ? param.map { |id| find_by(id: id) } : find_by(id: param)
    end

    private

    def is_integer?(str)
      str.to_i.to_s == str
    end
  end
end
