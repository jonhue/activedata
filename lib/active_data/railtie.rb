require 'rails/railtie'

module ActiveData
  class Railtie < Rails::Railtie

    initializer 'activedata.load' do
      ActiveData::Load.new(ObjectSpace.each_object(Class).select { |c| c.abstract_class && c.included_modules.include?(ActiveData::Model) }).perform
    end

  end
end
