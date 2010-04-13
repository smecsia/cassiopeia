require 'uri'
require 'cgi'
require 'net/https'
require 'rexml/document'

##################
# Client
##################
module Cassiopeia
  class CassiopeiaRequest < ActiveRecord::Base
  end

  class Client < Base
    SERVICE_URL = Cassiopeia::CONFIG[:service_url]
    SERVICE_ID = Cassiopeia::CONFIG[:service_id]
    SERVICE_URL_KEY = Cassiopeia::CONFIG[:service_url_key]
    SERVICE_ID_KEY = Cassiopeia::CONFIG[:service_id_key]
    TICKET_ID_KEY = Cassiopeia::CONFIG[:ticket_id_key]
    REQ_KEY = Cassiopeia::CONFIG[:rack_unique_req_key]
    private
    @instance = nil
    def server_url
      Cassiopeia::CONFIG[:server_url] + "/" + Cassiopeia::CONFIG[:server_controller] + "." + Cassiopeia::CONFIG[:format]
    end

    def cas_data(session, params)
      {
        SERVICE_URL_KEY => SERVICE_URL,
        SERVICE_ID_KEY => SERVICE_ID,
        TICKET_ID_KEY => session[TICKET_ID_KEY],
        REQ_KEY => params[REQ_KEY]
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

    def cas_current_ticket(session, request)
      res = do_post(server_url, cas_data(session, request))
      case res
      when Net::HTTPSuccess
        begin
          return ActiveSupport::JSON.decode(res.body).symbolize_keys if Cassiopeia::CONFIG[:format] == "js"
        rescue 
        end
      end 
      return {}
    end

    def cas_check_url(session, params)
      server_url + "?" + hash_to_query(cas_data(session, params))
    end

  end
end

