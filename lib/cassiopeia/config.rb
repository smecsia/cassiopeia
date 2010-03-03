require 'yaml'

module Cassiopeia
  private
  DEFAULT_CONFIG = {
    :ticket_max_lifetime => 120,
    :server_controller => "cas",
    :session_id_key => "cassiopeia_sesion_id",
    :ticket_id_key => "ticket_id",
    :service_id_key => "service_id",
    :service_url_key => "service_url",
    :server_url => "https://localhost/cassiopeia",
    :service_url => "https://localhost/test_rails",
    :service_id => "test",
    :current_user_key => "current_user"
  }
  CONFIG_PATH = "#{RAILS_ROOT}/config/cassiopeia.yml"
  @@conf = {}
  if !File.exist?(CONFIG_PATH)
    raise "Cassiopeia config required! Please, create RAILS_ROOT/conf/cassiopeia.yml file with server/service url"
  end
  @@conf = YAML::load(ERB.new((IO.read(CONFIG_PATH))).result).symbolize_keys if File.exist?(CONFIG_PATH)
  @@ticketClass = Class.class
  @@controllerClass = Class.class
  public
  CONFIG = DEFAULT_CONFIG.merge(@@conf)
end
