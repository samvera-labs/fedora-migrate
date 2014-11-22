module FedoraMigrate
  class Mover

    include MigrationOptions

    attr_accessor :target, :source

    def initialize *args
      @source = args[0]
      @target = args[1]
      @options = args[2]
      post_initialize
    end

    def post_initialize; end
    
  end
end
