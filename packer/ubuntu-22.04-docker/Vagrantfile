Vagrant.configure("2") do |config|

  config.vm.box = "myubuntu/server-22-04"

  config.vm.network "private_network", ip: "192.168.56.10"

  config.ssh.username = "codeworker"
  config.ssh.password = "Test123"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
  end

end
