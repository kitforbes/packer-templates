name 'provision'
maintainer 'Chris Forbes'
maintainer_email 'kitforbes@users.noreply.github.com'
license 'MIT'
description 'This cookbook is used to configure a system during provisioning with Packer.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.1'

# depends 'chocolatey'
# depends 'chocolatey_source'
# depends 'windows'
# depends 'wsus-client'

supports 'windows'

issues_url 'https://github.com/kitforbes/packer-templates/issues'
source_url 'https://github.com/kitforbes/packer-templates'
chef_version '>= 13' if respond_to?(:chef_version)
