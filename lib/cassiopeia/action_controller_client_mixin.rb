module Cassiopeia
  module ActionControllerClientMixin
    module ActionControllerMethods
      private
      ::CAS_USER_KEY = Cassiopeia::CONFIG[:current_user_key]
      ::CAS_TICKET_ID_KEY = Cassiopeia::CONFIG[:ticket_id_key] 
      ::CAS_TICKET_KEY = Cassiopeia::CONFIG[:ticket_key]
      ::CAS_UNIQUE_REQ_KEY = Cassiopeia::CONFIG[:rack_unique_req_key]
      def cas_current_ticket
        session[CAS_TICKET_KEY] || params[CAS_TICKET_KEY]
      end
      def cas_current_ticket_id
        return session[CAS_TICKET_ID_KEY] if (params[CAS_TICKET_ID_KEY].nil? || params[CAS_TICKET_ID_KEY].empty?)
        return params[CAS_TICKET_ID_KEY]
      end
      def cas_store_current_user(ticket, user)
        session[CAS_TICKET_KEY] = ticket
        session[CAS_USER_KEY] = current_user
      end
      def cas_erase_current_user
        cas_store_current_user nil, nil
        session[CAS_TICKET_ID_KEY] = nil
      end
      def cas_current_ticket_valid?
        logger.debug "\n Ticket.expires_at= #{cas_current_ticket[:expires_at]} \n" + "="*50 if cas_current_ticket
        logger.debug "\nCurrent ticket valid: #{DateTime.parse(cas_current_ticket[:expires_at])} >= #{DateTime.now}\n" + "="*50 if cas_current_ticket && cas_current_ticket[:expires_at]
        cas_current_ticket && DateTime.parse(cas_current_ticket[:expires_at]) >= DateTime.now if cas_current_ticket && cas_current_ticket[:expires_at]
      end
      def cas_request_ticket_id
        logger.debug "\nStoring current request:...#{params[CAS_UNIQUE_REQ_KEY]} \n" + "="*50
        redirect_to Cassiopeia::Client::instance.cas_check_url(session, params) 
      end
      def cas_request_current_user
        session[CAS_TICKET_ID_KEY] = cas_current_ticket_id
        @ticket = Cassiopeia::Client::instance.cas_current_ticket(session, params)
        raise Cassiopeia::Exception::AccessDenied.new "Cannot identify current user" unless (@ticket.include? :user)
        @current_user = Cassiopeia::User.new(@ticket[:user])
        logger.debug "\nCurrent user identified (#{@current_user.login}), storing to session\n" + "="*50
        cas_store_current_user(@ticket, @current_user)
        logger.debug "\nTicket_id is in request, should process the old request...#{params[CAS_UNIQUE_REQ_KEY]} \n" + "="*50
      end
      def cas_required_roles
        self.class.cas_required_roles if self.class.respond_to? :cas_required_roles 
      end
      def cas_check_required_roles
        if cas_required_roles
          logger.debug "\nCas check required roles #{cas_required_roles}...\n" + "="*50
          cas_required_roles.each do |r|
            raise Cassiopeia::Exception::AccessDenied.new "You don't have required roles for this controller" unless current_user.has_role? r
          end
        end
      end
      def cas_require_user
        if !cas_current_ticket_id
          logger.debug "\nNo cas_ticket_id, requesting from cassiopeia...\n" + "="*50
          return cas_request_ticket_id
        end
        if cas_current_ticket && !cas_current_ticket_valid?
          logger.debug "\nCurrent ticket is invalid, erasing current user\n" + "="*50
          cas_erase_current_user
          return cas_request_ticket_id
        end
        if cas_current_ticket_id && !cas_current_ticket
          logger.debug "\nCas ticket_id is in request, retrieving current_ticket and user...\n\n" + "="*50
          return cas_request_current_user
        elsif cas_current_ticket
          logger.debug "\nCurrent user session is valid (current user = #{current_user.login})\n" + "="*50
        end
      end
      def current_user
        return @current_user if @current_user
        @current_user = session[CAS_USER_KEY]
      end
    end
    def cas_required_roles
      @required_roles
    end
    def cas_require_roles(*roles)
      @required_roles = [] unless defined? @required_roles
      @required_roles |= roles
      logger.debug "\nCAS add required role #{roles}, now roles_required: #{@required_roles}...\n" + "="*50
    end
    def use_cas_authorization
      @current_user = nil
      before_filter :cas_require_user, :cas_check_required_roles
      include ActionControllerMethods
    end
  end
end
