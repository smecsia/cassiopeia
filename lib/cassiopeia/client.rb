require 'uri'
require 'cgi'
require 'net/https'
require 'rexml/document'

##################
# Client
##################
module Cassiopeia
  class Client < Base
    private
    @instance = nil
    def server_url
      Cassiopeia::CONFIG[:server_url] + "/" + Cassiopeia::CONFIG[:server_controller] + "." + Cassiopeia::CONFIG[:format]
    end

    def cas_data(session)
      {
        Cassiopeia::CONFIG[:service_url_key] => Cassiopeia::CONFIG[:service_url],
        Cassiopeia::CONFIG[:service_id_key] => Cassiopeia::CONFIG[:service_id],
        Cassiopeia::CONFIG[:ticket_id_key] => session[Cassiopeia::CONFIG[:ticket_id_key]]
      }
    end

    # Submits some data to the given URI and returns a Net::HTTPResponse.
    def do_post(uri, data)
      uri = URI.parse(uri) unless uri.kind_of? URI
      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(data, ';')
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = (uri.scheme == 'https')
      res = https.start {|conn| conn.request(req) }
    end

    public 
    def self.instance
      return @instance if @instance
      @instance = Cassiopeia::Client.new
    end

    def cas_current_ticket(session)
      res = do_post(server_url, cas_data(session))
      case res
      when Net::HTTPSuccess
        begin
          return ActiveSupport::JSON.decode(res.body).symbolize_keys if Cassiopeia::CONFIG[:format] == "js"
        rescue 
        end
      end 
      return {}
    end

    def cas_check_url(session)
      server_url + "?" + hash_to_query(cas_data(session))
    end

  end
end

