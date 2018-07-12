# frozen_string_literal: true

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
      def before_save(method)
        add_callback(:before_save_callbacks, method)
      end

      def after_save(method)
        add_callback(:after_save_callbacks, method)
      end

      def before_create(method)
        add_callback(:before_create_callbacks, method)
      end

      def after_create(method)
        add_callback(:after_create_callbacks, method)
      end

      def before_update(method)
        add_callback(:before_update_callbacks, method)
      end

      def after_update(method)
        add_callback(:after_update_callbacks, method)
      end

      def before_destroy(method)
        add_callback(:before_destroy_callbacks, method)
      end

      def after_destroy(method)
        add_callback(:after_destroy_callbacks, method)
      end

      def add_callback(method_names_method, method_name)
        method_names = send(method_names_method)
        method_names ||= []
        method_names << method_name unless method_names.include?(method_name)
        send("#{method_names_method}=", method_names)
      end
    end

    def exec_callbacks(callback, abort_with_false = false)
      valid = true
      self.class.send("#{callback}_callbacks")&.each do |method|
        valid = send(method)
        break if valid == false && abort_with_false
      end
      valid
    end
  end
end
