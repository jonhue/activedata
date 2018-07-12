# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'

class ActiveDataGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.join File.dirname(__FILE__), 'templates'
  desc 'Install activedata'

  def create_application_data
    template 'application_data.rb', 'app/models/application_data.rb'
  end
end
