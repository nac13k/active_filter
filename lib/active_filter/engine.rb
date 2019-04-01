require 'rails'

# Gem.load_specs['active_filter'].dependencies.each do |d|
#   require d.name
# end

module ActiveFilter
  class Engine < ::Rails::Engine
    initializer 'active_filter_engine.include_concerns' do
      ActiveRecord::Base.send(:include, ActiveRecordRelationFilterable)
    end
    
    protected

    def reloader_class
      if defined? ActiveSupport::Reloader
        ActiveSupport::Reloader
      else
        ActiveDispatch::Reloader
      end
    end
  end
end