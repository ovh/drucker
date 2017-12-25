# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "debian/stretch64"

  # Define this box so Vagrant doesn't call it "default"
  config.vm.define "vagrant-drucker"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  config.vm.provider "virtualbox" do |vb|

    # Display the VirtualBox GUI when booting the machine
    vb.gui = false

    # Name of the VM created in VirtualBox (Also the name of the subfolder in ~/VirtualBox VMs/ where this VM is kept)
    vb.name = "drucker"

    # Customize the amount of memory on the VM
    host = RbConfig::CONFIG['host_os']
    if host =~ /darwin/
      # sysctl returns Bytes and we need to convert to MB
      mem = `sysctl -n hw.memsize`.to_i / 1024
    elsif host =~ /linux/
      # meminfo shows KB and we need to convert to MB
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i
    elsif host =~ /mswin|mingw|cygwin/
      # Windows code via https://github.com/rdsubhas/vagrant-faster
      mem = `wmic computersystem Get TotalPhysicalMemory`.split[1].to_i / 1024
    end
    # Give VM 1/4 system memory
    mem = mem / 1024 / 4
    vb.customize ["modifyvm", :id, "--memory", mem]

  end

  # Update Guest Additions
  config.vbguest.auto_update = true

  # Sync the current folder in the workspace folder
  # @TODO: change here your local folder ("../"):
  config.vm.synced_folder "../", "/vagrant-mount"

  # BindFS workaround for MacOS (don't touch)
  config.bindfs.bind_folder "/vagrant-mount", "/home/vagrant/workspace"

  # @TODO: Ports forwarding, change it for your needs
  # Port forward for WWW:
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
  # Port forward for PHPMYADMIN:
  config.vm.network "forwarded_port", guest: 81, host: 8081, auto_correct: true

  # If a port collision occurs (e.g. port 8080 on local machine is in use),
  # then tell Vagrant to use the next available port between 8081 and 8100
  config.vm.usable_port_range = 8081..8100

  # Keep your host SSH keys when connecting to the guest
  config.ssh.forward_agent = true

  # Prevent annoying "stdin: is not a tty" errors from displaying during 'vagrant up'
  # See also https://github.com/mitchellh/vagrant/issues/1673#issuecomment-28288042
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Install Make
  config.vm.provision "shell", inline: <<-EOC
    sudo apt-get update

    # Install some useful tools
    sudo apt-get install -y make

    # Install GIT
    sudo apt-get install -y git
  EOC

  # Check if ~/.gitconfig exists locally
  # If so, copy basic Git Config settings to Vagrant VM
  # This lets developers easily commit code to GitHub as themselves
  if File.exists?(File.join(Dir.home, ".gitconfig"))
    git_name = `git config user.name`   # find locally set git name
    git_email = `git config user.email` # find locally set git email
    # set git name for 'vagrant' user on VM
    config.vm.provision :shell, :inline => "echo 'Saving local git username to VM...' && sudo -i -u vagrant git config --global user.name '#{git_name.chomp}'"
    # set git email for 'vagrant' user on VM
    config.vm.provision :shell, :inline => "echo 'Saving local git email to VM...' && sudo -i -u vagrant git config --global user.email '#{git_email.chomp}'"
  end

  # Install docker
  config.vm.provision :docker

  # Install docker-compose
  config.vm.provision "docker-compose", type: "shell", inline: <<-EOC
    sudo curl -s -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    docker --version
    docker-compose --version
  EOC

  # Some cleanup
  config.vm.provision "shell", inline: <<-EOC
    sudo apt-get clean -y
    sudo apt-get autoremove --purge -y
    sudo rm -rf /var/lib/apt/lists/*
  EOC

  # Message to display to user after 'vagrant up' completes
  config.vm.post_up_message = "*** Vagrant - Drucker ***\nSetup is now COMPLETE!\nYou can SSH into the new VM via 'vagrant ssh'.\nDon't forget to run 'ssh-add' to be able to use your local SSH credentials."

end
