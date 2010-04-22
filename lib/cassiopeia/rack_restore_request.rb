module Cassiopeia
  class RackRestoreRequest < BaseRack
    def call( env )
      if enabled
        if restore_headers_required?(env)
          env = restore_old_request(env)
        elsif store_headers_required?(env)
          remove_expired_requests
          store_current_request(env)
        end
      end
      response(env)
    end

    def store_current_request(env)
      begin
        request = CassiopeiaRequest.new({:uid => store_req_key(env), :expires_at => generate_expiration})
        store = {}
        env.each do |key,value|
          if env[key] && (key.is_a? String) && (key.match("HTTP_") || CAS_SAVE_KEYS.match(key))
            store[key] = value
          end
        end
        request.data = Marshal.dump(store)
        request.save!
      rescue Exception => e
        raise_missconfiguration(e)
      end
    end


    def restore_old_request(env)
      begin
        key = restore_req_key(env)
        request = CassiopeiaRequest.find_by_uid(key)
        stored_keys = Marshal.load(request.data)
        stored_keys.each do |key,value|
          if(key.match(CAS_QUERY_STRING_KEY))
            add_ticket_id_to_req(env,key,value)
          else
            env[key] = value
          end
        end
        #FIXME: should we delete this request? But what if user press F5 key?
        request.delete if CAS_REQ_REMOVE_RETURN
      rescue Exception => e
        raise_missconfiguration(e)
      end
      env
    end

    def remove_expired_requests
      begin
        CassiopeiaRequest.delete_all(["expires_at <= ?", Time.now.utc])
      rescue Exception => e
        raise_missconfiguration(e)
      end
    end

    def store_req_key(env)
      params = query_to_hash(env[CAS_QUERY_STRING_KEY])
      params[CAS_UNIQUE_REQ_KEY] = generate_req_key
      env[CAS_QUERY_STRING_KEY] = hash_to_query(params)
      params[CAS_UNIQUE_REQ_KEY]
    end


    def restore_req_key(env)
      newparams = query_to_hash(env[CAS_QUERY_STRING_KEY])
      newparams[CAS_UNIQUE_REQ_KEY]
    end

    def add_ticket_id_to_req(env, key, value)
      newparams = query_to_hash(value)
      params = query_to_hash(env[key])
      newparams[CAS_TICKET_ID_KEY] = params[CAS_TICKET_ID_KEY]
      newparams.delete CAS_UNIQUE_REQ_KEY
      env[key] = hash_to_query(newparams)
    end
  end
end
