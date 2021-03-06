module Cassiopeia
  autoload :TicketsControllerConfig, 'cassiopeia/tickets_controller_config'

  module ActionControllerServerMixin
    module ActionControllerMethods
      private
      def cas_ticket_id
        return session[@ticket_id_key] if (params[@ticket_id_key].nil? || params[@ticket_id_key].empty?)
        return params[@ticket_id_key]
      end
      def cas_service_url
        params[@service_url_key] || session[@service_url_key]
      end
      def cas_service_id
        params[@service_id_key] || session[@service_id_key]
      end

      def cas_require_config
        unless Cassiopeia::CONFIG[:ticketClass]
          raise ConfigRequired.new "ticketClass should be set to use this functionality"
        end
      end

      def cas_store_params
        @ticket_id_key = Cassiopeia::CONFIG[:ticket_id_key]
        @service_id_key = Cassiopeia::CONFIG[:service_id_key]
        @service_url_key = Cassiopeia::CONFIG[:service_url_key]
        session[@ticket_id_key] = cas_ticket_id
        session[@service_id_key] = cas_service_id
        session[@service_url_key] = cas_service_url
      end

      def cas_create_or_find_ticket
        if current_user && !(cas_current_ticket_exists?) 
          @ticket = Cassiopeia::CONFIG[:ticketClass].new(:user_id => current_user.id)
          @ticket.user = current_user
          @ticket.service = cas_service_id
          if @ticket.save
            session[@ticket_id_key] = @ticket.identity
            session[@service_id_key] = @ticket.service
          else
            @ticket = nil
          end
        else
          @ticket = Cassiopeia::CONFIG[:ticketClass].find_by_identity(cas_ticket_id.to_s)
        end
        @ticket
      end

      def cas_current_ticket
        @ticket = cas_create_or_find_ticket unless @ticket
        @ticket
      end

      def cas_current_ticket_exists?
        Cassiopeia::CONFIG[:ticketClass].exists?(cas_ticket_id) 
      end

      def cas_current_ticket_valid?
        logger.debug("\nTicketValid = #{cas_current_ticket.valid_for?(cas_service_id)}\n" + "="*50) if cas_current_ticket_exists?
        cas_current_ticket.valid_for?(cas_service_id) if cas_current_ticket_exists?
      end

      def cas_respond_current_ticket
        ticket_hash = cas_current_ticket.attributes
        if cas_current_ticket.user
          user_hash = cas_current_ticket.user.attributes
          roles = []
          roles = (cas_current_ticket.user.send Cassiopeia::CONFIG[:rolesMethod]) if cas_current_ticket.user.respond_to? Cassiopeia::CONFIG[:rolesMethod]
          roles_hash = roles
          user_hash[:roles] = roles_hash
        else
          user_hash = nil
        end
        ticket_hash = ticket_hash.merge({:user => user_hash}) if cas_current_ticket.user
        logger.debug "\n Rendering ticket: \n"
        logger.debug ticket_hash.to_json + "\n" + "="*50
        cas_respond ticket_hash, {:status => :ok}
      end

      def cas_process_request
        if current_user || cas_current_ticket_exists?
          cas_respond_current_ticket
        else
          @res = {:error => "Ticket not found"}
          cas_respond @res, {:status => :error}
        end
      end

      def cas_redirect_to(url)
        unless url
          logger.debug "\n Cannot detect url (params = #{params.to_json}, session = #{session.to_json} \n" + "="*50
          raise Cassiopeia::Exception::InvalidUrl.new "Cannot detect url for redirection! Please, check configuration."
        end
        redirect_to url
      end

      def cas_service_url_build
        Cassiopeia::Server::instance.service_url(session, params)
      end

      def cas_proceed_auth        
        Thread.exclusive do
          if cas_current_ticket_valid? && current_user
            logger.debug "\nCurrentTicketValid, current_user exists redirecting to service...\n" + "="*50
            return cas_redirect_to cas_service_url_build
          elsif current_user
            logger.debug "\nCurrentTicketInvalid, but current_user exists, should create new ticket...\n" + "="*50
            cas_current_ticket.destroy if cas_current_ticket_exists?
            cas_create_or_find_ticket
            return cas_redirect_to cas_service_url_build
          elsif cas_current_ticket_exists?
            logger.debug "\nCurrentTicketInvalid, but current_user exists, destroying ticket, redirecting to login...\n" + "="*50
            cas_current_ticket.destroy
          end
        end
        cas_redirect_to login_url
      end

      def cas_remove_expired_tickets
        Cassiopeia::CONFIG[:ticketClass].delete_all(:conditions => ["expired_at <= '?'", Time.now.utc])
      end

      def cas_respond(data, opts)
        status= opts[:status] || :ok
        respond_to do |format|
          format.js { render :json => data.to_json({}),:status=>status}
          format.yaml { render :partial=> 'shared/inspect',:content_type =>'text/html',:locals => { :data => data } ,:status=>status }
          format.xml  { render :xml => data.to_xml({}),:status=>status}
        end
      end

      public

      def create
        cas_process_request
      end

      def show
        cas_proceed_auth
      end

      def index
        cas_proceed_auth
      end

      def detroy(params)
        cas_current_ticket.destroy if cas_current_ticket_exists?
        cas_respond nil, {:status => :ok}
      end
    end
    def acts_as_cas_controller
      defaultTicketClass = ((defined? Ticket)?(Ticket):(Class))
      defaultConfig = {
        :ticketClass => defaultTicketClass, 
        :rolesMethod => :roles
      }
      controllerConfig = Cassiopeia::TicketsControllerConfig.new defaultConfig
      yield controllerConfig
      Cassiopeia::CONFIG[:rolesMethod], Cassiopeia::CONFIG[:ticketClass] = controllerConfig.rolesMethod, controllerConfig.ticketClass
      skip_before_filter :verify_authenticity_token, :only=> [:create, :index]
      before_filter :require_user, :except => [:create, :index]
      before_filter :cas_store_params, :cas_create_or_find_ticket, :cas_require_config
      include ActionControllerMethods
    end
  end
end
