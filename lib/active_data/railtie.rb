require 'rails/railtie'

module ActiveData
  class Railtie < Rails::Railtie

    initializer 'activedata.load' do
      ActiveData::Load.new(ObjectSpace.each_object(Class).select { |c| c.included_modules.include?(ActiveData::Model) && !c.abstract_class }).perform
    end

  end
end
