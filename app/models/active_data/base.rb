class ActiveData::Base
  include ActiveData::Model
end

ActiveSupport.run_load_hooks(:active_data, ActiveData::Base)
