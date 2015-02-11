module FedoraMigrate
  class TargetConstructor

    attr_accessor :candidates, :target

    def initialize candidates
      @candidates = candidates
    end

    def build
      determine_target
      return self
    end

    private

    def determine_target
      case
        when @candidates.kind_of?(Array) then vote
        when @candidates.kind_of?(String) then vet(@candidates)
      end
    end

    def vote
      candidates.each do |model|
        vet(model)
        return unless @target.nil?
      end
    end

    def vet model
      @target = FedoraMigrate::Mover.id_component(model).constantize
    rescue NameError
      Logger.debug "rejecting #{model} for target"
    end

  end
end
