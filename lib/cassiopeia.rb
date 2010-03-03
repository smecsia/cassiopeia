$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
module Cassiopeia
  VERSION = '0.0.1'
  autoload :User, 'cassiopeia/user'
  autoload :Base, 'cassiopeia/base'
  autoload :AccessDeniedException, 'cassiopeia/base'
  autoload :Server, 'cassiopeia/server'
  autoload :Client, 'cassiopeia/client'
  autoload :CONFIG, 'cassiopeia/config'
  autoload :ActiveRecordServerMixin, 'cassiopeia/active_record_server_mixin'
  autoload :ActionControllerServerMixin, 'cassiopeia/action_controller_server_mixin'
  autoload :ActionControllerClientMixin, 'cassiopeia/action_controller_client_mixin'

  class << self
    def enable
      ActionController::Base.send :extend, ActionControllerServerMixin
      ActiveRecord::Base.send :extend, ActiveRecordServerMixin
      ActionController::Base.send :extend, ActionControllerClientMixin
    end
  end
end

if defined? Rails && defined? RAILS_ROOT
  Cassiopeia.enable
end
