#
# Vagrantfile for use in testing the distribution point
#

name = "mirror-test"
default_box = "almalinux/9"


Vagrant.configure("2") do |config|

    if Vagrant.has_plugin?("vagrant-vbguest")
      # Don't allow upgrades; the box has what it has.
      config.vbguest.auto_update = false
    end

    # Basic configuration

    config.vm.provider "virtualbox" do |vbox|
      # The default E1000 has a security vulerability.
      vbox.default_nic_type = "82543GC"
      vbox.cpus = 2
      vbox.memory = 4096
      config.vm.box = default_box
      config.vm.hostname = name
    end

    unless Vagrant.has_plugin?("vagrant-disksize")
      raise  Vagrant::Errors::VagrantError.new, "vagrant-disksize plugin is missing. Please install it using 'vagrant plugin install vagrant-disksize' and rerun 'vagrant up'"
    end
    config.disksize.size = '100GB'


    #
    # Podman
    #

    config.vm.provision "podman", type: "shell", run: "once", inline: <<-SHELL

        dnf -y install \
            podman \
            podman-docker \
	    podman-compose \
            git

	systemctl enable --now podman

	# No Podman-isn't-Docker warnings
	touch /etc/containers/nodocker

        # Don't complain about network file system stroage
        sed -i -e '/^\s*force_mask\s*=\s*/d' /etc/containers/storage.conf
        sed -i -e 's/\(\[storage\.options\.overlay\]\)/\1\nforce_mask = "700"\n/' /etc/containers/storage.conf

    SHELL

end


# -*- mode: ruby -*-
# vi: set ft=ruby :
