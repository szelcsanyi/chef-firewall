maintainer       'Gabor Szelcsanyi'
maintainer_email 'szelcsanyi.gabor@gmail.com'
license          'MIT'
description      'Installs/Configures firewall'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.5'
name             'firewall'

%w( ubuntu debian ).each do |os|
  supports os
end
