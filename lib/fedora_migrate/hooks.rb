# Override this methods to perform additional actions before and after
# migation of objects and datastreams.
#
# To do so, simply define a FedoraMigrate::Hooks module anywhere in
# you application and substitute methods for the ones listed below
module FedoraMigrate
  module Hooks
    # Called from FedoraMigrate::ObjectMover
    def before_object_migration
    end

    # Called from FedoraMigrate::ObjectMover
    def after_object_migration
    end

    # Called from FedoraMigrate::RDFDatastreamMover
    def before_rdf_datastream_migration
    end

    # Called from FedoraMigrate::RDFDatastreamMover
    def after_rdf_datastream_migration
    end

    # Called from FedoraMigrate::DatastreamMover
    def before_datastream_migration
    end

    # Called from FedoraMigrate::DatastreamMover
    def after_datastream_migration
    end
  end
end
