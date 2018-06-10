require 'active_model'

module ActiveData
  class Model
    include ActiveModel::Model

    cattr_accessor :all
  end
end
