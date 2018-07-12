# frozen_string_literal: true

require 'rails/railtie'

module ActiveData
  class Railtie < Rails::Railtie
    initializer 'activedata.load' do
      ActiveSupport.on_load :active_data do
        if defined?(ApplicationData)
          ApplicationData.descendants&.each do |klass|
            klass.dataset.load unless klass.delay_loading?
          end
        end
      end
    end
  end
end
