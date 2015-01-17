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
      @target = model.split(/:/).last.constantize
      Logger.info "using #{model} for target"
    rescue NameError
      Logger.info "rejecting #{model} for target"
    end

  end
end
