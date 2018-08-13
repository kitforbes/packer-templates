return unless platform_family?('windows')

directory 'Remove old panther directory' do
  path "#{ENV['SystemRoot']}/Panther"
  recursive true
  action :delete
end

directory 'create unattend directory' do
  path "#{ENV['SystemRoot']}/Panther/Unattend"
  recursive true
  action :create
end

template "#{ENV['SystemRoot']}/Panther/Unattend/unattend.xml" do
  source 'postunattend.xml.erb'
  action :create
end

template "#{ENV['SystemRoot']}/Panther/Unattend/packer_shutdown.cmd" do
  source 'packer_shutdown.cmd.erb'
  variables(
    post_unattend: "#{ENV['SystemRoot']}/Panther/Unattend/unattend.xml"
  )
  action :create
end
