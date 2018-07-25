return unless platform_family?('windows')

include_recipe 'chocolatey::default'

chocolatey_source 'chocolatey' do
  source 'https://chocolatey.org/api/v2/'
  action :add
end
