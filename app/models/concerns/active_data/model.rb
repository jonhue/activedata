require 'active_support'
require 'active_model'

module ActiveData
  module Model
    extend ActiveSupport::Concern
    include ActiveModel::Model

    include ActiveData::Callbacks
    include ActiveData::Associations

    included do
      cattr_accessor :all, :dataset
      cattr_reader :active_data_config
      attr_accessor :id

      include ClassMethods
    end

    module ClassMethods
      def active_data(options = {})
        @@active_data_config = {}
        @@active_data_config[:file_name] = options[:file_name]
        @@active_data_config[:json_scope] = options[:json_scope]
        @@active_data_config[:permit_attributes] = options[:permit_attributes]
      end

      def create(options = {})
        instance = self.class.new
        return false unless instance.exec_callbacks(:before_create, true)
        options.each { |k, v| instance.send("#{k}=", v) }
        if instance.save
          instance.exec_callbacks(:after_create)
          instance
        else
          nil
        end
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

      def dataset
        @@dataset ||= Dataset.new(self.class)
      end

      def explicit_ids?
        self.explicit_ids || self.explicit_ids.nil?
      end
    end

    def save
      return false unless exec_callbacks(:before_save, true)
      if valid?
        self.class.dataset.write(self)
        exec_callbacks(:after_save)
        self
      else
        false
      end
    end

    def update(options = {})
      return false unless exec_callbacks(:before_update, true)
      fallback = self
      options.each { |k, v| send("#{k}=", v) }
      if save
        exec_callbacks(:after_update)
        self
      else
        fallback
      end
    end

    def update_attributes(options = {})
      update(options)
    end

    def update_attribute(attribute, value)
      update("#{attribute}": value)
    end

    def destroy
      return false unless exec_callbacks(:before_destroy, true)
      if self.class.dataset.remove(self)
        @destroyed = true
        exec_callbacks(:after_destroy)
      end
      self
    end

    def destroyed?
      @destroyed
    end

    private

    def is_integer?(str)
      str.to_i.to_s == str
    end
  end
end
