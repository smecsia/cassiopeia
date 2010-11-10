require "rails"

module Cassiopeia
  class Railtie < Rails::Railtie
    autoload :CONFIG, 'config'

    initializer 'cassiopeia.init_config' do
      Cassiopeia.enable
      config.middlewares.use Cassiopeia::RackRestoreRequest if CONFIG[:service_id]
    end
  end
end