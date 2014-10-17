module FedoraMigrate
  class Mover

    attr_accessor :target, :source

    def initialize *args
      @source = args[0]
      @target = args[1]
    end
    
  end
end