# frozen_string_literal: true

require 'active_support'
require 'active_model'

module ActiveData
  module Model
    extend ActiveSupport::Concern
    include ActiveModel::Model

    include ActiveData::Callbacks
    include ActiveData::Associations

    included do
      attr_accessor :id

      @active_data_config = {}

      include ClassMethods
    end

    module ClassMethods
      def dataset
        @dataset ||= ActiveData::Dataset.new(self)
      end

      def active_data(options = {})
        @active_data_config = options
      end

      def create(options = {})
        instance = self.class.new
        return false unless instance.exec_callbacks(:before_create, true)
        options.each { |k, v| instance.send("#{k}=", v) }
        if instance.save
          instance.exec_callbacks(:after_create)
          return instance
        end
        nil
      end

      def where(options = {})
        all.select do |instance|
          if options.is_a?(Hash)
            options.map { |k, v| instance.send(k) == v }.none?(false)
          else
            a, operator, b = options.split(' ').map do |str|
              integer?(str) ? str.to_i : instance.send(str)
            end
            send(a).send(operator, b)
          end
        end
      end

      def find_by(options = {})
        where(options).first
      end

      def find(param)
        if param.is_a?(Array)
          param.map { |id| find_by(id: id) }
        else
          find_by(id: param)
        end
      end

      def all
        ObjectSpace.each_object(self).to_a
                   .reject { |instance| instance.id.nil? }.sort_by(&:id)
      end

      def first
        all&.first
      end

      def last
        all&.last
      end

      def count
        all&.count || 0
      end

      def explicit_ids?
        @active_data_config[:explicit_ids] ||
          @active_data_config[:explicit_ids].nil?
      end

      def explicit_nulls?
        @active_data_config[:explicit_ids] ||
          @active_data_config[:explicit_ids].nil?
      end

      def delay_loading?
        @active_data_config[:delay_loading]
      end

      def prohibit_writes?
        @active_data_config[:prohibit_writes]
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

    def integer?(str)
      str.to_i.to_s == str
    end
  end
end
