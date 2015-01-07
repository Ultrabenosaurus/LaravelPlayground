VAGRANTFILE_API_VERSION = "2"

path = "#{File.dirname(__FILE__)}"

# require path + '/.vg-scripts/VagrantMySQL.rb'
# vgsql = VagrantMySQL.init( false, "homestead", "secret" )

require 'yaml'
require path + '/.vg-scripts/homestead.rb'

Vagrant.configure( VAGRANTFILE_API_VERSION ) do |config|

  config.vm.define "homestead" do |homestead|

    Homestead.configure( homestead, YAML::load( File.read( path + '/.vg-scripts/Homestead.yaml' ) ) )
    # vgsql.processFiles( homestead )

    homestead.trigger.after :destroy do
      run "git checkout -- " + path + "/.vagrant/machines/homestead/virtualbox/dummy.txt"
    end

  end

end
