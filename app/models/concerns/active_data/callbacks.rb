require 'active_support'

module ActiveData
  module Callbacks
    extend ActiveSupport::Concern

    included do
      cattr_accessor :before_save_callbacks, :after_save_callbacks,
        :before_create_callbacks, :after_create_callbacks,
        :before_update_callbacks, :after_update_callbacks,
        :before_destroy_callbacks, :after_destroy_callbacks

      include ClassMethods
    end

    module ClassMethods
      def before_save(m)
        add_callback(:before_save_callbacks, m)
      end

      def after_save(m)
        add_callback(:after_save_callbacks, m)
      end

      def before_create(m)
        add_callback(:before_create_callbacks, m)
      end

      def after_create(m)
        add_callback(:after_create_callbacks, m)
      end

      def before_update(m)
        add_callback(:before_update_callbacks, m)
      end

      def after_update(m)
        add_callback(:after_update_callbacks, m)
      end

      def before_destroy(m)
        add_callback(:before_destroy_callbacks, m)
      end

      def after_destroy(m)
        add_callback(:after_destroy_callbacks, m)
      end

      class << self
        private

        def add_callback(method_names_method, method_name)
          method_names = send(method_names_method)
          method_names ||= []
          method_names << method_name unless method_names.include?(method_name)
          send("#{method_names_method}=", method_names)
        end
      end
    end

    def exec_callbacks(callback, abort_with_false = false)
      valid = true
      self.class.send("#{callback}_callbacks")&.each do |m|
        valid = send(m)
        break if valid == false && abort_with_false
      end
      valid
    end
  end
end
