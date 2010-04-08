module Cassiopeia
  class RackRestoreRequest
    CAS_RACK_SESSION_STORE = Cassiopeia::CONFIG[:rack_session_store] 
    CAS_RACK_SESSION_KEY = Cassiopeia::CONFIG[:rack_session_key]
    CAS_TICKET_ID_KEY = Cassiopeia::CONFIG[:ticket_id_key]
    CAS_REQUEST_URI_KEY = Cassiopeia::CONFIG[:rack_request_uri_key]
    CAS_QUERY_STRING_KEY = Cassiopeia::CONFIG[:rack_query_string_key]
    CAS_SAVE_KEYS = Cassiopeia::CONFIG[:rack_save_keys]
    CAS_UNIQUE_REQ_KEY = Cassiopeia::CONFIG[:rack_unique_req_key]

    def initialize( app )
      @app = app
    end

    def call( env )
      if restore_headers_required?(env)
        env = restore_headers(env)
      else
        save_headers(env)
      end
      @status, @headers, @body = @app.call env
      [@status, @headers, @body]
    end

    def query_to_hash(query)
      CGI.parse(query)
    end

    def hash_to_query(hash)
      pairs = []
      hash.each do |k, vals|
        vals = [vals] unless vals.kind_of? Array
        vals.each {|v| pairs << "#{CGI.escape(k.to_s)}=#{(v)?CGI.escape(v.to_s):''}"}
      end
      pairs.join("&")
    end

    def restore_headers_required?(env)
      env[CAS_QUERY_STRING_KEY] && env[CAS_QUERY_STRING_KEY].match(CAS_TICKET_ID_KEY.to_s) && env[CAS_RACK_SESSION_KEY] && env[CAS_RACK_SESSION_KEY][CAS_RACK_SESSION_STORE]
    end

    def save_headers(env)
      if(env[CAS_RACK_SESSION_KEY])
        req_key = store_req_key(env)
        env[CAS_RACK_SESSION_KEY][CAS_RACK_SESSION_STORE] = { req_key => {}}
        env.each do |key,value|
          if env[key] && (key.is_a? String) && (key.match("HTTP_") || CAS_SAVE_KEYS.match(key))
            env[CAS_RACK_SESSION_KEY][CAS_RACK_SESSION_STORE][req_key][key] = value
          end
        end
      end
    end

    def add_ticket_id_to_req(env, key, value)
      newparams = query_to_hash(value)
      params = query_to_hash(env[key])
      newparams[CAS_TICKET_ID_KEY] = params[CAS_TICKET_ID_KEY]
      newparams.delete CAS_UNIQUE_REQ_KEY
      env[key] = hash_to_query(newparams)
    end

    def restore_req_key(env)
      newparams = query_to_hash(env[CAS_QUERY_STRING_KEY])
      newparams[CAS_UNIQUE_REQ_KEY]
    end

    def store_req_key(env)
      params = query_to_hash(env[CAS_QUERY_STRING_KEY])
      params[CAS_UNIQUE_REQ_KEY] = UUIDTools::UUID.timestamp_create.to_s
      env[CAS_QUERY_STRING_KEY] = hash_to_query(params)
      params[CAS_UNIQUE_REQ_KEY]
    end

    def restore_headers(env)
      current_req_key = restore_req_key(env)
      stored_keys = env[CAS_RACK_SESSION_KEY][CAS_RACK_SESSION_STORE][current_req_key.to_s]
      if(env[CAS_RACK_SESSION_KEY] && stored_keys)
        stored_keys.each do |key,value|
          if(key.match(CAS_QUERY_STRING_KEY))
            add_ticket_id_to_req(env,key,value)
          else
            env[key] = value
          end
        end
        env[CAS_RACK_SESSION_KEY][CAS_RACK_SESSION_STORE].delete current_req_key.to_s
      end
      env
    end
  end
end
