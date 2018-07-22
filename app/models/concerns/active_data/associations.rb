# frozen_string_literal: true

require 'active_support'

module ActiveData
  module Associations
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :has_many_associations, :belongs_to_associations
      end

      @has_many_associations = {}
      @belongs_to_associations = {}

      # rubocop:disable Naming/PredicateName
      def self.has_many(name, options = {})
        has_many_associations[name.to_sym] = options
      end
      # rubocop:enable Naming/PredicateName

      def self.belongs_to(name, options = {})
        belongs_to_associations[name.to_sym] = options
        attr_accessor :"#{options[:foreign_key] || name}_id"
        return unless options[:polymorphic]
        attr_accessor :"#{options[:foreign_key] || name}_type"
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

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Naming/PredicateName
      def has_many_association(name)
        options = self.class.has_many_associations[name.to_sym]
        if options[:as]
          has_many_polymorphic_association(options[:as])
        elsif options[:class_name]
          has_many_association_with_custom_class_name(
            options[:class_name],
            options[:foreign_key] || self.class.name.underscore
          )
        else
          foreign_key = options[:foreign_key] || self.class.name.underscore
          name.camelize.constantize.where("#{foreign_key}_id": id)
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def has_many_polymorphic_association(key)
        send("#{key}_type").constantize.where("#{key}_id": id)
      end

      def has_many_association_with_custom_class_name(class_name, foreign_key)
        class_name.constantize.where("#{foreign_key}_id": id)
      end

      def has_many_association?(method)
        self.class.has_many_associations&.key?(method.to_sym)
      end
      # rubocop:enable Naming/PredicateName

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def belongs_to_association(name)
        options = self.class.belongs_to_associations[name.to_sym]
        if options[:polymorphic]
          belongs_to_polymorphic_association(options[:foreign_key] || name)
        elsif options[:class_name]
          belongs_to_association_with_custom_class_name(
            options[:class_name],
            options[:foreign_key] || name
          )
        else
          foreign_key = options[:foreign_key] || name
          name.camelize.constantize.find(send("#{foreign_key}_id"))
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def belongs_to_polymorphic_association(foreign_key)
        send("#{foreign_key}_type").constantize.find(send("#{foreign_key}_id"))
      end

      def belongs_to_association_with_custom_class_name(class_name, foreign_key)
        class_name.constantize.find(send("#{foreign_key}_id"))
      end

      def belongs_to_association?(method)
        self.class.belongs_to_associations&.key?(method.to_sym)
      end
    end
  end
end
