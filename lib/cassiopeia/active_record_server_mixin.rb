require 'uuidtools'

module Cassiopeia
  module ActiveRecordServerMixin 
    def ActiveRecordServerMixin.ticketClass=(c)
      @@ticketClass = c
    end
    # cas ticket
    def acts_as_cas_ticket
      class_eval do
        def valid_for?(service)
          return false unless identity && user
          (ticket = self.for_service service) && ticket.expires_at >= DateTime.now
        end
        def for_service(service)
          @@ticketClass.find(:first, :conditions => {:service => service, :user_id => user.id })
        end
      end
      instance_eval do
        def generate_expiration
          DateTime.now() + Cassiopeia::CONFIG[:ticket_max_lifetime] / 24.0 / 60.0
        end
        def generate_uuid
          UUIDTools::UUID.timestamp_create.to_s
        end
        def exists?(ticket_id)
          self.find_by_identity(ticket_id.to_s) != nil
        end
        before_create do |obj|
          obj.identity = generate_uuid
          obj.expires_at = generate_expiration
        end
      end
    end
  end
end
