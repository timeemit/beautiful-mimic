require 'yaml'

CONFIG = YAML::load_file(File.expand_path('app/environments/development.yml', __dir__))

Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = 'ubuntu/trusty64'

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network 'private_network', ip: '10.1.1.11'

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder '.', '/opt/code'

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider 'virtualbox' do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true
  
    # Customize the amount of memory on the VM:
    vb.memory = '1024'

  end

  config.vm.define 'behemoth', primary: true do |compute|
    compute.vm.provision 'chef_zero' do |chef|
      chef.add_recipe 'web'
      chef.add_recipe 'app'
      chef.add_recipe 'db'
      chef.add_recipe 'redis'
    end
  end

  config.vm.define 'mongodb' do |compute|
    compute.vm.provision 'ansible' do |ansible|
      ansible.playbook = './ops/playbooks/mongodb.yml'
    end
  end

  config.vm.define 'compute' do |compute|
    compute.vm.provision 'ansible' do |ansible|
      ansible.playbook = './ops/playbooks/compute.yml'
    end
  end

  config.vm.define 'sidekiq' do |sidekiq|
    sidekiq.vm.provision 'ansible' do |ansible|
      ansible.playbook = './ops/playbooks/sidekiq.yml'
      ansible.verbose = 'v'
    end
  end

  config.vm.define 'generator' do |generator|
    generator.vm.box = 'dummy'
    generator.vm.synced_folder '.', '/vagrant', disabled: true

    generator.vm.provider :aws do |aws, override|
      aws.access_key_id = CONFIG['AWS']['access_key_id']
      aws.secret_access_key = CONFIG['AWS']['secret_access_key']
      aws.instance_type = 'g2.2xlarge'
      aws.region = 'us-west-2'
      aws.ami = 'ami-e9bf6089'
      aws.block_device_mapping = [{ 'DeviceName' => '/dev/xvda', 'Ebs.VolumeSize' => 50 }]
      aws.keypair_name = 'beautiful-mimic'
      aws.elastic_ip = true
      aws.ssh_host_attribute = :public_ip_address
      override.ssh.username = 'ec2-user'
      override.ssh.private_key_path = '/Users/liamnorris1231853211/.ssh/beautiful-mimic.pem'
    end

    generator.vm.provision 'ansible' do |ansible|
      ansible.playbook = './ops/playbooks/generator.yml'
      ansible.verbose = 'vvvv'
    end
  end
end
