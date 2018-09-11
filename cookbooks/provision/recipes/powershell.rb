return unless platform_family?('windows')

# TODO: Add powershell_package_source resource
powershell_script 'NuGet' do
  code <<-EOH
  Find-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 |
      Install-PackageProvider -Force -Confirm:$false
  EOH
  only_if '(Get-PackageProvider -Name NuGet -ListAvailable | Where-Object -Property Version -eq 2.8.5.208) -eq $null'
end

if Mixlib::Versioning.parse(node['chef_packages']['chef']['version']) < Mixlib::Versioning.parse('14.3.0')
  powershell_script 'PSGallery' do
    code <<-EOH
    Register-PSRepository -Default
    EOH
    only_if '[Boolean](Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue) -eq $false'
  end
else
  powershell_package_source 'PSGallery' do
    url 'https://www.powershellgallery.com/api/v2/'
    trusted false
    action :register
  end
end

# Includes 'PackageManagement'
powershell_package 'PowerShellGet' do
  version '1.6.0'
  action :install
end

# Dependency of 'PowerShellGet'
# powershell_package 'PackageManagement' do
#   version '1.1.7.0'
#   action :install
# end

%w(
  PowerShellGet
  PackageManagement
).each do |ps_module|
  powershell_script "remove-builtin-#{ps_module}" do
    code <<-EOH
    $module = Get-Module -Name #{ps_module} -ListAvailable | Where-Object -Property Version -eq 1.0.0.1
    Remove-Module $module.Name -Force -Confirm:$false
    Remove-Item -Path $module.ModuleBase -Force -Recurse
    EOH
    not_if "(Get-Module -Name #{ps_module} -ListAvailable | Where-Object -Property Version -eq 1.0.0.1) -eq $null"
  end
end
