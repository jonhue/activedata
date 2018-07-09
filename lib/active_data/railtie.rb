require 'rails/railtie'

module ActiveData
  class Railtie < Rails::Railtie

    initializer 'activedata.load' do
      ActiveData::Load.new(ApplicationData.descendants).perform if defined?(ApplicationData)
    end

  end
end
