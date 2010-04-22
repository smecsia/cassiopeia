require(File.join(RAILS_ROOT,"config/environment")) unless defined?(Rails)
module Cassiopeia
  class BaseRack < Base
    CAS_RACK_SESSION_STORE = Cassiopeia::CONFIG[:rack_session_store] 
    CAS_RACK_SESSION_KEY = Cassiopeia::CONFIG[:rack_session_key]
    CAS_TICKET_ID_KEY = Cassiopeia::CONFIG[:ticket_id_key]
    CAS_TICKET_KEY = Cassiopeia::CONFIG[:ticket_key]
    CAS_REQUEST_URI_KEY = Cassiopeia::CONFIG[:rack_request_uri_key]
    CAS_QUERY_STRING_KEY = Cassiopeia::CONFIG[:rack_query_string_key]
    CAS_SAVE_KEYS = Cassiopeia::CONFIG[:rack_save_keys]
    CAS_UNIQUE_REQ_KEY = Cassiopeia::CONFIG[:rack_unique_req_key]
    CAS_REQ_EXPIRES_AT_KEY = Cassiopeia::CONFIG[:rack_session_store_expires_at_key]
    CAS_REQ_TIMEOUT = Cassiopeia::CONFIG[:rack_session_store_timeout]
    CAS_REQ_REMOVE_RETURN = Cassiopeia::CONFIG[:rack_remove_req_after_return]

    def session(env)
      env[CAS_RACK_SESSION_KEY]
    end

    def cas_current_ticket(env)
      session(env)[CAS_TICKET_KEY]
    end

    def cas_current_ticket_valid?(env)
      @ticket = cas_current_ticket(env)
      @ticket && DateTime.parse(@ticket[:expires_at]) >= DateTime.now if @ticket && @ticket[:expires_at]
    end

    def enabled
      Cassiopeia::CONFIG[:requests_save_enabled]
    end

    def initialize( app )
      @app = app
    end

    def response( env )
      @status, @headers, @body = @app.call env
      [@status, @headers, @body]
    end

    def restore_headers_required?(env)
      env[CAS_QUERY_STRING_KEY] && env[CAS_QUERY_STRING_KEY].match(CAS_TICKET_ID_KEY.to_s) && env[CAS_RACK_SESSION_KEY]
    end

    def store_headers_required?(env)
      !cas_current_ticket_valid?(env)
    end

    def generate_expiration
      DateTime.now() + CAS_REQ_TIMEOUT / 24.0 / 60.0
    end

    def generate_req_key
      UUIDTools::UUID.timestamp_create.to_s
    end

    def raise_missconfiguration(msg)
      raise Cassiopeia::Exception::MissConfiguration.new "Cannot modify or delete cassiopeia request instance! Please, create table casssiopeia_requests[:uid, :expires_at, :data] or disable requests saving in configuration! (#{msg})"
    end
  end
end
