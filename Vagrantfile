#
# Copyright (c) 2024 Balamurugan Kandan
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# -*- mode: ruby -*-
# vi: set ft=ruby :
#
Vagrant.require_version ">= 1.7.0"

VM_NAME = "epics"
WS_NAME = (VM_NAME + "_ws")

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  PROJECT_ROOT = File.expand_path(File.join(File.dirname(File.expand_path(__FILE__)), '..'))
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "almalinux/8"
  config.vm.provider "virtualbox" do |vb|
    config.vm.box_version = "8.9.20231219"
  end
  config.vm.provider "libvirt" do |v, override|
    override.vm.box_version = "8.9.20231125"
  end

  config.vm.disk :disk, size: "50GB", primary: true

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder WS_NAME, "/home/vagrant/" + WS_NAME, type: 'nfs', nfs_version: 4, nfs_udp: false

  # Disable the default share of the current code directory. Doing this
  # provides improved isolation between the vagrant box and your host
  # by making sure your Vagrantfile isn't accessable to the vagrant box.
  # If you use this you may want to enable additional shared subfolders as
  # shown above.
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.hostname = VM_NAME 
  config.vm.define VM_NAME
  config.vm.provider :virtualbox do |vb|
    vb.name = VM_NAME
  end

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "libvirt" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
     vb.memory = "512"
     vb.cpus = 1 
   end
   config.vm.provider "virtualbox" do |v, override|
     override.memory = "2048"
     override.cpus = 2
   end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  #
  config.vm.provision :shell, :path => "./scripts/swap.sh", :args => "2G"
  config.vm.provision :shell, :path => "./scripts/bootstrap.sh", :args => "rhel"   
  config.vm.provision :shell, :path => "./scripts/clone_epicsbase.sh", :args => "/home/vagrant/'#{WS_NAME}'", :privileged => false
  config.vm.provision :shell, :path => "./scripts/epicsbase_exports.sh", :args => "/home/vagrant/'#{WS_NAME}'"
  config.vm.provision :shell, :path => "./scripts/build_epicsbase.sh", :args => "/home/vagrant/'#{WS_NAME}'", :privileged => false
  config.vm.provision :shell, :path => "./scripts/build_epics_support.sh", :args => "/home/vagrant/'#{WS_NAME}'", :privileged => false
end
