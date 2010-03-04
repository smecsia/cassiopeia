module Cassiopeia
  class Base
    protected
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
  end

  module Exception
    class AccessDenied < Object::Exception
    end
    class InvalidUrl < Object::Exception
    end
  end
end
