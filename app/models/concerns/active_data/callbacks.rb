require 'active_support'

module ActiveData
  class Callbacks
    extend ActiveSupport::Concern

    included do
      cattr_accessor :before_save, :after_save,
        :before_create, :after_create,
        :before_update, :after_update,
        :before_destroy, :after_destroy
    end

    def before_save(m)
      add_callback(@@before_save, m)
    end

    def after_save(m)
      add_callback(@@after_save, m)
    end

    def before_create(m)
      add_callback(@@before_create, m)
    end

    def after_create(m)
      add_callback(@@after_create, m)
    end

    def before_update(m)
      add_callback(@@before_update, m)
    end

    def after_update(m)
      add_callback(@@after_update, m)
    end

    def before_destroy(m)
      add_callback(@@before_destroy, m)
    end

    def after_destroy(m)
      add_callback(@@after_destroy, m)
    end

    def run_callbacks(callback, abort_with_false = false)
      valid = true
      self.class.send(callback)&.each do |m|
        valid = method(m)
        break if valid == false && abort_with_false
      end
      valid
    end

    private

    def add_callback(method_names, method_name)
      method_names ||= []
      method_names << method_name unless method_names.include?(method_name)
    end
  end
end
