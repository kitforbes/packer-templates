directory 'C:\Users\vagrant\.ssh' do
  action :create
end

remote_file 'C:\Users\vagrant\.ssh\authorized_keys' do
  source 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub'
  action :create
end

execute 'disable-password-expiration' do
  command 'wmic useraccount where "name=\'vagrant\'" set PasswordExpires=FALSE'
  action :run
end

registry_key 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System' do
  values [{
    name: 'EnableLUA',
    type: :dword,
    data: 0,
  }]
end
