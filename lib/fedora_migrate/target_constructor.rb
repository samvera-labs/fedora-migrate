module FedoraMigrate
  class TargetConstructor
    attr_accessor :source, :candidates, :target

    def initialize(source)
      @source = source
    end

    def build
      raise FedoraMigrate::Errors::MigrationError, "No qualified targets found in #{source.pid}" if target.nil?
      target.new(id: FedoraMigrate::Mover.id_component(source))
    end

    def target
      @target ||= determine_target
    end

    private

      def determine_target
        Array(candidates).map { |model| vet(model) }.compact.first
      end

      def vet(model)
        klass = class_from_model(model)
        klass ||= namespaced_class_from_model(model)
        Logger.debug "rejecting #{model} for target" if klass.nil?
        klass
      end

      def class_from_model(model)
        FedoraMigrate::Mover.id_component(model).constantize
      rescue NameError
        nil
      end

      def namespaced_class_from_model(model)
        FedoraMigrate::Mover.id_component(model).split(/_/).map(&:camelize).join('::').constantize
      rescue NameError
        nil
      end

      def candidates
        @candidates ||= source.models
      end
  end
end
