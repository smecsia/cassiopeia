module Cassiopeia
  class Server < Base
    private
    @instance = nil
    def cas_data(session)
      {
        Cassiopeia::CONFIG[:ticket_id_key] => session[Cassiopeia::CONFIG[:ticket_id_key]]
      }
    end
    public 
    def self.instance
      return @instance if @instance
      @instance = Cassiopeia::Server.new
    end

    def service_url(session)
      session[Cassiopeia::CONFIG[:service_url_key]] + "?" + hash_to_query(cas_data(session))
    end

  end
  
end
