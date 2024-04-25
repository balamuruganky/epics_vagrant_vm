# vagrant_epics_vm
Vagrant AlmaLinux 8.9 VM creation for EPICS workspace for development purpose

## System requirements
* CPU : Atleast 4 [2 CPUs are for VM]
* Memory : Atleast 4GB [2GB for VM]

## Vagrant Providers Support
* Oracle Virtual-Box [Windows and Linux]
* Libvirt [Linux Only]

## How to setup NFS server in host machine
* Please follow the instructions [https://developer.hashicorp.com/vagrant/docs/synced-folders/nfs]

## How to create VM on Oracle Virtual-Box
* Install Oracle VirtualBox [https://www.virtualbox.org/wiki/Downloads]
* Install Vagrant [https://developer.hashicorp.com/vagrant/install]
* git clone https://github.com/balamuruganky/vagrant_epics_vm
* cd vagrant_epics_vm
* vagrant up [By default, Oracle Virtual-Box is the provider, if it is installed.]

## How to use KVM on Linux instead of using Oracle VirtualBox
* Install Vagrant [https://developer.hashicorp.com/vagrant/install]
* git clone https://github.com/balamuruganky/vagrant_epics_vm
* cd vagrant_epics_vm
* vagrant up --provider libvirt

## How to login to VM
* vagrant ssh
* cd epics_ws [EPICS workspace containing all the necessary builds]

## How to shutdown the VM
* vagrant halt

## How to destroy the VM
* vagrant destroy

## Network
This VM has no public IP assigned. Please use "nmtui" utility in AlmaLinux VM to configure the network.

## Useful links
* https://developer.hashicorp.com/vagrant/docs/providers
* https://developer.hashicorp.com/vagrant/docs/plugins

