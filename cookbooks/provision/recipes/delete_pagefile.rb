return unless platform_family?('windows')

# windows_pagefile 'delete pagefile' do
#   path ''
#   action :delete
# end

registry_key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' do
  values [{
    name: 'PagingFiles',
    type: :string,
    data: '',
  }]
end
