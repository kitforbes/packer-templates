return unless platform_family?('windows')

powershell_package 'PSWindowsUpdate' do
  version '2.0.0.4'
  action :install
end
