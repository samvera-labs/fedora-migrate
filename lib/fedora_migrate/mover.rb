module FedoraMigrate
  class Mover

    include MigrationOptions
    include Hooks

    attr_accessor :target, :source

    def initialize *args
      @source = args[0]
      @target = args[1]
      @options = args[2]
      post_initialize
    end

    def post_initialize
    end

    def save
      if target.save
        Logger.info "success for target UID #{target_description}"
      else
        raise FedoraMigrate::Errors::MigrationError, "Failed to save target: #{target_errors}"
      end
    end

    def target_errors
      if target.respond_to?(:errors)
        target.errors.full_messages.join(" -- ")
      else
        target.inspect
      end
    end

    def target_description
      if target.respond_to?(:id)
        target.id
      else
        target.inspect
      end
    end

    def id_component object=nil
      object ||= source
      raise FedoraMigrate::Errors::MigrationError, "can't get the id component without an object" if object.nil?
      self.class.id_component(object)
    end

    def self.id_component object
      return object.pid.split(/:/).last if object.kind_of?(Rubydora::DigitalObject)
      return object.to_s.split(/:/).last if object.respond_to?(:to_s)
      nil
    end
    
  end
end
