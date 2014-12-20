# FedoraMigrate [![Version](https://badge.fury.io/gh/projecthydra-labs%2Ffedora-migrate.png)](http://badge.fury.io/gh/projecthydra-labs%2Ffedora-migrate) [![Build Status](https://travis-ci.org/projecthydra-labs/fedora-migrate.png?branch=master)](https://travis-ci.org/projecthydra-labs/fedora-migrate)

Migrates content from a Fedora3 repository to a Fedora4 one.

## Status

Very alpha. This has been tested against Penn State's existing Scholarsphere applications, as well
as generic Sufia applications.

## Overview

FedoraMigrate iterates over your existing Fedora3 application using the Rubydora gem. For each object it finds, it
creates a new object with the same id in Fedora4 and proceeds to migrate each datastream, including versions if
they are defined, and verifies the checksum of each. Permissions and relationships are migrated as well but using
different procedures due to the changes in Fedora4.

The entire migration process takes place in two steps. In the first, all objects, including datastreams and permissions,
are copied over to Fedora4; in the second, relationships are migrated.

## Requirements

1. A working Hydra application using Fedora4
2. An existing Fedora3 instance
3. All models defined in your Hydra/Fedora4 application

## Usage

Add the fedora-migrate gem to your existing Fedora4-based Hydra head

    gem 'fedora-migrate'

Then run `bundle update`

Create a `config/fedora3.yml` file and point it to your current Fedora3 repository

    development:
      user: fedoraAdmin
      password: fedoraAdmin
      url: http://localhost:8983/fedora3
    test:
      user: fedoraAdmin
      password: fedoraAdmin
      url: http://localhost:8983/fedora3
    production:
      user: fedoraAdmin
      password: fedoraAdmin
      url: http://localhost:8983/fedora3

Create a rake task to migrate your repository. You can use the following, taken from `lib/tasks/fedora-migrate.rake`,
as an example:

    desc "Migrate all my objects"
    task migrate: :environment do
      results = FedoraMigrate.migrate_repository(namespace: "mynamespace")
      puts results
    end

Run the task

    bundle exec rake migrate

By default, messages are logged to your Rails environment logs.

## Configuration

FedoraMigrate uses your existing Hydra/Fedora4 application as the basis for migrating objects. For example,
given the model

    class MyModel < ActiveFedora::Base
      contains "content", class_name: "ActiveFedora::File"
      contains "thumbnail", class_name: "ActiveFedora::File"
    end

When the migrator finds an object in your Fedora3 repository that has the name _MyModel_ it attempts to instantiate the
object `MyModel` in the context of your Hydra application. Only the datastreams, or files, that are defined in the model will
be migrated from Fedora3. This means if your Fedora3 object has the datastream "special" but it is not in your Hydra
model, it will not be migrated. DC datastreams are not migrated by default, and RELS-EXT and rightsMetdata datastreams are treated
differently. See [FedoraMigrate::RelsExtDatastreamMover](rels_ext_datastream_mover.rb) and
[FedoraMigrate::PermissionsMover](permissions_mover.rb).

If your model contains a file or datastream that is versioned, then all versions of that datastream will be migrated from
Fedora3. If the model does not define something as versioned, yet the Fedora3 datastream is versioned, then only the current
version will be migrated to Fedora4.

### RDF Conversion

If you elect to do so, FedoraMigrate will attempt to convert ActiveFedora::NtriplesRDFDatastream objects into RDF properties
defined on your object. You can configure this as an option passed to the migrator.

    FedoraMigrate.migrate_repository(namespace: "mynamespace", options: {convert: "descMetadata"})

However, you are required to define any and all RDF properties on your object in Hydra. For example, given

    class RDFObject < ActiveFedora::Base
      property :title, predicate: ::RDF::DC.title do |index|
        index.as :stored_searchable, :facetable
      end
      contains "content", class_name: "ActiveFedora::File"
      contains "thumbnail", class_name: "ActiveFedora::File"
    end

If your descMetadata RDF datastream in Fedora3 contains the triple

    <info:fedora/mynamespace:xp68km39w> <http://purl.org/dc/terms/title> "My Title" .

Then FedoraMigrate will define that property on your Fedora4 object using the DC term. *Note:* this feature currently works with
DC terms only.

### Object Migration

By default, FedoraMigrate will use a model definition in your Hydra application to migrate a model found in Fedora3. You can
opt to provide your own model, if you wish, by passing it as a second argument to the object mover class.

    source = FedoraMigrate.source.connection.find("mynamespace:rb68xc089")
    mover = FedoraMigrate::ObjectMover.new source, CustomObject.new
    mover.migrate

### Configuration Hooks

Because the migration process will be different for each user, there are before and after methods that
are executed around the object migration process. These are helpful if your target object in Fedora4 requires
additional preparation before it can be migrated. A good example is in Sufia, where a depositor must be applied
before the object can be saved.

To use the hooks, simply define them in your migration task

    module FedoraMigrate::Hooks

      # Both @source and @target are available, as the Rubydora object and ActiveFedora model, respectively
    
      # Apply depositor metadata before you migrate an object
      def before_object_migration
        xml = Nokogiri::XML(source.datastreams["properties"].content)
        target.apply_depositor_metadata xml.xpath("//depositor").text
      end
    
      def after_object_migration
        # additional actions as needed
      end
    
    end

    desc "Migrate all my objects"
    task migrate: :environment do
      results = FedoraMigrate.migrate_repository(namespace: "mynamespace", options: {convert: "descMetadata"})
      puts results
    end

## Testing

Execute `bundle exec rake` to run the test suite. Afterwards,

    bundle exec rake jetty:clean jetty:start
    bundle exec rake fixtures:load
    bundle exec rspec

Will run all the spec tests and leave jetty running if you wish to run specific tests.

If you have sample objects that you feel should be used as relevant testing examples, please add them to
`spec/fixtures/objects` and re-run the tests. Sample objects should be exported from existing Fedora3
repositories as foxml files using the "archive" option. This can be done via the admin web interface,
[http://localhost:8983/fedora3/admin](http://localhost:8983/fedora3/admin), or using the fedora-export.sh 
command under `FEDORA_HOME/client/bin`. Note that the script option is available to full installs of Fedora3 but
may not work under hydra-jetty.

## TODOs and Reporting Errors

See the list of issues for current bugs and feature needs. Add your own as needed.

## Contributing

### Hydra Developers

For Hydra developers, or anyone with a signed CLA, please clone the repo and submit PRs via
feature branches. If you don't have rights to projecthydra-labs and do have a signed
CLA, please send a note to hydra-tech@googlegroups.com.

1. Clone it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Non-Hydra Developers

Anyone is welcome to use this software and report issues.
In order to merge any work contributed, you'll need to sign a contributor license agreement.
