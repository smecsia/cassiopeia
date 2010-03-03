module Cassiopeia
  class TicketsControllerConfig
    attr_accessor :ticketClass
    attr_accessor :rolesMethod
    def initialize(tClass, rMethod)
      @ticketClass = tClass
      @rolesMethod = rMethod
    end
  end
end
