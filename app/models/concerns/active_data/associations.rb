# frozen_string_literal: true

require 'active_support'

module ActiveData
  module Associations
    extend ActiveSupport::Concern

    included do
      cattr_reader :has_many_associations, :belongs_to_associations

      include ClassMethods
    end

    module ClassMethods
      def has_many(name, options = {})
        @@has_many_associations ||= {}
        @@has_many_associations[name.to_sym] = options
      end

      def belongs_to(name, options = {})
        @@belongs_to_associations ||= {}
        @@belongs_to_associations[name.to_sym] = options
        attr_accessor :"#{options[:foreign_key] || name}_id"
        if options[:polymorphic]
          attr_accessor :"#{options[:foreign_key] || name}_type"
        end
      end
    end

    def method_missing(method, *args)
      if has_many_association?(method)
        has_many_association(method)
      elsif belongs_to_association?(method)
        belongs_to_association(method)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      super || association?(method)
    end

    private

    def has_many_association(name)
      options = self.class.has_many_associations[m.to_sym]
      if options[:as]
        send("#{options[:as]}_type").constantize.where("#{options[:as]}_id": id)
      elsif options[:class_name]
        options[:class_name].constantize.where(
          "#{options[:foreign_key] || self.class.name.underscore}_id": id
        )
      else
        name.camelize.constantize.where(
          "#{options[:foreign_key] || self.class.name.underscore}_id": id
        )
      end
    end

    def has_many_association?(method)
      self.class.has_many_associations&.key?(method.to_sym)
    end

    def belongs_to_association(name)
      options = self.class.belongs_to_associations[m.to_sym]
      if options[:polymorphic]
        send("#{options[:foreign_key] || name}_type").constantize.find(
          send("#{options[:foreign_key] || name}_id")
        )
      elsif options[:class_name]
        options[:class_name].constantize.find(
          send("#{options[:foreign_key] || name}_id")
        )
      else
        name.camelize.constantize.find(
          send("#{options[:foreign_key] || name}_id")
        )
      end
    end

    def belongs_to_association?(method)
      self.class.belongs_to_associations&.key?(method.to_sym)
    end
  end
end
