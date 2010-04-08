module Cassiopeia
  class Server < Base
    SERVICE_KEY = Cassiopeia::CONFIG[:service_url_key]
    TICKET_KEY = Cassiopeia::CONFIG[:ticket_id_key]
    REQ_KEY = Cassiopeia::CONFIG[:rack_unique_req_key]
    private
    @instance = nil
    def cas_data(session, params)
      {
        TICKET_KEY => session[TICKET_KEY],
        REQ_KEY => params[REQ_KEY]
      }
    end
    public 
    def self.instance
      return @instance if @instance
      @instance = Cassiopeia::Server.new
    end

    def service_url(session, params)
      if session && session[SERVICE_KEY] && session[TICKET_KEY]
        session[SERVICE_KEY] + "?" + hash_to_query(cas_data(session, params))
      end
    end

  end

end
