return unless platform_family?('windows')

powershell_package 'PSWindowsUpdate' do
  version '2.0.0.4'
  action :install
end

powershell_package 'xNetworking' do
  version '5.7.0.0'
  action :install
end

powershell_package 'xRemoteDesktopAdmin' do
  version '1.1.0.0'
  action :install
end

powershell_package 'xCertificate' do
  version '3.2.0.0'
  action :install
end
