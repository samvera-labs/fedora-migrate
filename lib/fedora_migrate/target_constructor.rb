module FedoraMigrate
  class TargetConstructor
    attr_accessor :candidates, :target

    def initialize(candidates)
      @candidates = candidates
    end

    def build
      determine_target
      self
    end

    private

      def determine_target
        case
        when @candidates.is_a?(Array) then vote
        when @candidates.is_a?(String) then vet(@candidates)
        end
      end

      def vote
        candidates.each do |model|
          vet(model)
          break unless @target.nil?
        end
      end

      def vet(model)
        @target = FedoraMigrate::Mover.id_component(model).constantize
      rescue NameError
        Logger.debug "rejecting #{model} for target"
      end
  end
end
