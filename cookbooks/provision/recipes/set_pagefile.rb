return unless platform_family?('windows')

windows_pagefile 'set pagefile' do
  automatic_managed true
  action :set
end
