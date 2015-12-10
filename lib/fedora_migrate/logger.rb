module FedoraMigrate
  class Logger
    class << self
      def method_missing(method_name, *arguments, &block)
        logger.send(method_name, *arguments, &block)
      rescue
        super
      end

      def respond_to?(method_name, _include_private = false)
        logger.respond_to? method_name
      end

      def info(msg)
        super("FedoraMigrate INFO: ##{caller_locations(1, 1)[0].label} " + msg)
      end

      def warn(msg)
        super("FedoraMigrate WARN: ##{caller_locations(1, 1)[0].label} " + msg)
      end

      def fatal(msg)
        super("FedoraMigrate FATAL: ##{caller_locations(1, 1)[0].label} " + msg)
      end

      private

      def logger
        ActiveFedora::Base.logger || ::Logger.new(STDOUT)
      end
    end
  end
end
