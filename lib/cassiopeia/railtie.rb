require "rails"

module Cassiopeia
  class Railtie < Rails::Railtie
    initializer 'cassiopeia.init_config' do
      Cassiopeia.enable
      config.middleware.use Cassiopeia::RackRestoreRequest if Cassiopeia::CONFIG[:service_id]
    end
  end
end