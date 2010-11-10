$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require "cassiopeia/railtie"

module Cassiopeia
  VERSION = '0.2.0'
  autoload :User, 'cassiopeia/user'
  autoload :Base, 'cassiopeia/base'
  autoload :Exception, 'cassiopeia/base'
  autoload :Server, 'cassiopeia/server'
  autoload :Client, 'cassiopeia/client'
  autoload :ActiveRecordServerMixin, 'cassiopeia/active_record_server_mixin'
  autoload :ActionControllerServerMixin, 'cassiopeia/action_controller_server_mixin'
  autoload :ActionControllerClientMixin, 'cassiopeia/action_controller_client_mixin'
  autoload :RackRestoreRequest, 'cassiopeia/rack_restore_request'
  autoload :BaseRack, 'cassiopeia/base_rack'
  autoload :CassiopeiaRequest, 'cassiopeia/client'
  autoload :CONFIG, 'cassiopeia/config'

  class << self
    def enable
      ActionController::Base.send :extend, ActionControllerServerMixin
      ActiveRecord::Base.send :extend, ActiveRecordServerMixin
      ActionController::Base.send :extend, ActionControllerClientMixin
      puts "Cassiopeia #{VERSION} enabled"
    end
  end
end
