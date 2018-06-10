require 'active_support'
require 'active_data/version'

module ActiveData
  extend ActiveSupport::Autoload

  autoload :Model

  require 'active_data/engine'
end
