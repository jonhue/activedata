require 'active_support'
require 'active_data/version'

module ActiveData
  extend ActiveSupport::Autoload

  autoload :Dataset
  autoload :Load

  require 'active_data/railtie'
  require 'active_data/engine'
end
