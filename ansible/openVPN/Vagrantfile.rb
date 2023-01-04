Vagrantfile
mode: ruby
# vi: set fturuby
Vagrant.configure("2") do |config|
config.vm.box = "ubuntu/focal 64*
config.vm.network "public_network", pride: "and: Wi-Fi (wireless)"
config-vm,network "forwarded_port", guest: 80, host: 8080
config.vm.synced_folder "--/data", "/vagrant_data"
config.vm.provider *virtualbox" do | vb|
Display the VirtualBox GUI when booting the machine
vb-gui = true
Customize the amount of memory on the
vb.memory = H7024*
Enable provisioning with a shell script. Additional provisions such as
Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
documentation for more information about their specific syntax and use.
config-vm,provision "shell", inline: <<-SHELL
apt-get update
apt get install -y apache2
# SHELL
end