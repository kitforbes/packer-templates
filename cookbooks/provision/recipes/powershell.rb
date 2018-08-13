return unless platform_family?('windows')

powershell_script 'NuGet' do
  code <<-EOH
  Find-PackageProvider -Name NuGet -RequiredVersion 2.8.5.208 |
      Install-PackageProvider -Force -Confirm:$false
  EOH
  only_if '(Get-PackageProvider -Name NuGet -ListAvailable | Where-Object -Property Version -eq 2.8.5.208) -eq $null'
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

powershell_script 'remove-builtin-PowerShellGet' do
  code <<-EOH
  $module = Get-Module -Name PowerShellGet -ListAvailable | Where-Object -Property Version -eq 1.0.0.1
  Remove-Module $module.Name -Force -Confirm:$false
  Remove-Item -Path $module.ModuleBase -Force -Recurse
  EOH
  not_if '(Get-Module -Name PowerShellGet -ListAvailable | Where-Object -Property Version -eq 1.0.0.1) -eq $null'
end

powershell_script 'remove-builtin-PackageManagement' do
  code <<-EOH
  $module = Get-Module -Name PackageManagement -ListAvailable | Where-Object -Property Version -eq 1.0.0.1
  Remove-Module $module.Name -Force -Confirm:$false
  Remove-Item -Path $module.ModuleBase -Force -Recurse
  EOH
  not_if '(Get-Module -Name PackageManagement -ListAvailable | Where-Object -Property Version -eq 1.0.0.1) -eq $null'
end
