module Cassiopeia
  class Server < Base
    private
    @instance = nil
    def cas_data(session)
      {
        TICKET_KEY => session[TICKET_KEY]
      }
    end
    public 
    def self.instance
      return @instance if @instance
      @instance = Cassiopeia::Server.new
      SERVICE_KEY = Cassiopeia::CONFIG[:service_url_key]
      TICKET_KEY = Cassiopeia::CONFIG[:ticket_id_key]
    end

    def service_url(session)
      if session && session[SERVICE_KEY] && session[TICKET_KEY]
        session[SERVICE_KEY] + "?" + hash_to_query(cas_data(session))
      end
    end

  end

end
