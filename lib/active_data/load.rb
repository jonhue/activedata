require 'active_support'

module ActiveData
  class Load
    def initialize(classes)
      @classes = classes
    end

    def perform
      @classes&.each do |c|
        Dataset.new(c).load
      end
    end
  end
end
