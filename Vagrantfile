# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.define 'windows', primary: true do |windows|
    # windows.vm.box = 'win2012r2'
    windows.vm.box = 'win2016'

    # windows.vm.hostname = 'windows'
    windows.vm.network 'private_network', bridge: 'External Vagrant'
    windows.vm.synced_folder '.', '/vagrant', disabled: true
    windows.vm.provider 'hyperv' do |machine|
      machine.vmname = 'windows'
      machine.memory = 2048
    end
    windows.winrm.port = 5986
    windows.winrm.timeout = 1200
  end
end
