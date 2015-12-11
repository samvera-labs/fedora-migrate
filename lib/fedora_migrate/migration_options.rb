module FedoraMigrate
  module MigrationOptions
    attr_accessor :options, :conversions

    def conversion_options
      self.conversions = options.nil? ? [] : [options[:convert]].flatten
    end

    def forced?
      option_true?(:force)
    end

    def not_forced?
      !forced?
    end

    def application_creates_versions?
      option_true?(:application_creates_versions)
    end

    def blacklist
      return [] if options.nil?
      options.fetch(:blacklist, [])
    end

    private

      def option_true?(name)
        return false unless options
        options.fetch(name, false)
      end
  end
end
