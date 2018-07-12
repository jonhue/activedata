# frozen_string_literal: true

module ActiveData
  class Base
    include ActiveData::Model
  end
end

ActiveSupport.run_load_hooks(:active_data, ActiveData::Base)
