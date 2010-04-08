require 'yaml'

module Cassiopeia
  private
  DEFAULT_CONFIG = {
    :ticket_max_lifetime => 120,
    :server_controller => "cas",
    :session_id_key => "cassiopeia_sesion_id",
    :ticket_id_key => "cas_ticket_id",
    :service_id_key => "cas_service_id",
    :service_url_key => "cas_service_url",
    :server_url => nil,
    :service_url => nil,
    :webpath_prefix => "",
    :return_to_key => "cas_return_to",
    :service_id => nil,
    :current_user_key => "current_user",
    :format => "js",
    :rack_session_store => "cas_rack_session",
    :rack_session_key => "rack.session",
    :rack_request_uri_key => "REQUEST_URI",
    :rack_query_string_key => "QUERY_STRING",
    :rack_save_keys => "REQUEST_METHOD QUERY_STRING REQUEST_URI",
    :rack_unique_req_key => "cas_req_key"
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
