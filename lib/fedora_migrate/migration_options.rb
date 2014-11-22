module FedoraMigrate
  module MigrationOptions

    attr_accessor :options, :conversions

    def conversion_options
      self.conversions = options.nil? ? [] : [options[:convert]].flatten      
    end

  end
end
