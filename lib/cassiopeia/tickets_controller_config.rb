module Cassiopeia
  class TicketsControllerConfig
    attr_accessor :ticketClass
    attr_accessor :rolesMethod
    def initialize(opts={})
      @ticketClass, @rolesMethod = opts[:ticketClass], opts[:rolesMethod]
    end
  end
end
