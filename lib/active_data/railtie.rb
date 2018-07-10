require 'rails/railtie'

module ActiveData
  class Railtie < Rails::Railtie

    initializer 'activedata.load' do
      ActiveSupport.on_load :active_data do
        if defined?(ApplicationData)
          ApplicationData.descendants&.each do |c|
            c::DATASET.load unless c.delay_loading?
          end
        end
      end
    end

  end
end
