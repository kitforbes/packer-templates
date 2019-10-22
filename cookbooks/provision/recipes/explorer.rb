return unless platform_family?('windows')

registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder' do
  values [
    {
      name: 'HideFileExt',
      type: :dword,
      data: 0,
    },
    {
      name: 'Hidden',
      type: :dword,
      data: 1,
    },
  ]
  action :create
end
