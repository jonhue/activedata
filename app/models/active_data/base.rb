class ActiveData::Base
  include ActiveData::Model

  ActiveSupport.run_load_hooks(:active_data, ActiveData::Base)
end
