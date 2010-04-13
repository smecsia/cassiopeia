$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
module Cassiopeia
  VERSION = '0.1.0'
  autoload :User, 'cassiopeia/user'
  autoload :Base, 'cassiopeia/base'
  autoload :Exception, 'cassiopeia/base'
  autoload :Server, 'cassiopeia/server'
  autoload :Client, 'cassiopeia/client'
  autoload :CONFIG, 'cassiopeia/config'
  autoload :ActiveRecordServerMixin, 'cassiopeia/active_record_server_mixin'
  autoload :ActionControllerServerMixin, 'cassiopeia/action_controller_server_mixin'
  autoload :ActionControllerClientMixin, 'cassiopeia/action_controller_client_mixin'
  autoload :RackRestoreRequest, 'cassiopeia/rack_restore_request'
  autoload :BaseRack, 'cassiopeia/base_rack'
  autoload :CassiopeiaRequest, 'cassiopeia/client'

  class << self
    def enable
      ActionController::Base.send :extend, ActionControllerServerMixin
      ActiveRecord::Base.send :extend, ActiveRecordServerMixin
      ActionController::Base.send :extend, ActionControllerClientMixin
      Rails.configuration.middleware.use RackRestoreRequest if CONFIG[:service_id]
      puts "Cassiopeia 0.1.0 enabled"
    end
  end
end

if defined? Rails && defined? RAILS_ROOT
  Cassiopeia.enable
end
