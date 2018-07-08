require 'active_support'

module ActiveData
  module Associations
    extend ActiveSupport::Concern

    included do
      cattr_accessor :has_many, :belongs_to
    end

    def has_many(name, options = {})
      @@has_many ||= []
      @@has_many << { name: name.to_sym, options: options }
    end

    def belongs_to(name, options = {})
      @@belongs_to ||= []
      @@belongs_to << { name: name.to_sym, options: options }
    end

    def method_missing m, *args
      if has_many_association?(m)
        has_many_association(m)
      elsif belongs_to_association?(m)
        belongs_to_association(m)
      else
        super
      end
    end

    def respond_to? m, include_private = false
      super || association?(m)
    end

    private

    def has_many_association(name)
      options = @@has_many.select { |association| association[:name] == m }.first[:options]
      if options.key?(:class_name)
        options[:class_name].constantize.where("#{options[:foreign_key] || self.class.name + '_id'}": id)
      else
        name.camelize.constantize.where("#{options[:foreign_key] || self.class.name + '_id'}": id)
      end
    end

    def has_many_association?(m)
      @@has_many&.any? { |association| association[:name] == m }
    end

    def belongs_to_association(name)
      options = @@belongs_to.select { |association| association[:name] == m }.first[:options]
      if options.key?(:class_name)
        options[:class_name].constantize.find(send(options[:foreign_key] || name + '_id'))
      else
        name.camelize.constantize.find(send(options[:foreign_key] || name + '_id'))
      end
    end

    def belongs_to_association?(m)
      @@belongs_to&.any? { |association| association[:name] == m }
    end
  end
end
