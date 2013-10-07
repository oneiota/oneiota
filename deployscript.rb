module DeployScript
  class << self
    def registered(app, options_hash={}, &block)
      app.after_build do |builder|
        builder.run './deploy_script.sh'
      end
    end
  end
end

::Middleman::Extensions.register(:deployScript, DeployScript)