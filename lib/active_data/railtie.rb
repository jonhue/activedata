require 'rails/railtie'

module ActiveData
  class Railtie < Rails::Railtie

    initializer 'activedata.load' do
      ActiveSupport.on_load :activedata do
        if defined?(ApplicationData)
          ApplicationData.descendants&.each do |c|
            c.dataset.load unless c.delay_loading?
          end
        end
      end
    end

  end
end
