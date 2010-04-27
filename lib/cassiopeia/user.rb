require 'ostruct'

module Cassiopeia
  class User < OpenStruct
    def to_json(o)
      table.to_json(o)
    end

    def initialize(hash)
      super(hash)
    end

    def has_role?(role)
      roles && roles.respond_to?(:include?) && roles.include?(role.to_s)
    end
  end
end
