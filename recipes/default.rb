# The firewall template
class Chef
  # Recipe
  class Recipe
    include FirewallTemplate
  end
end

package 'iptables' do
  action [:install, :upgrade]
  options '--force-yes'
end

r = gem_package 'ipaddr_extensions' do
  version '1.0.1'
  action :nothing
  if ::File.exist?('/opt/chef/embedded/bin/gem')
    gem_binary '/opt/chef/embedded/bin/gem'
  end
end
r.run_action(:install)
Gem.clear_paths

template '/etc/init.d/firewall' do
  source 'etc/init.d/firewall.erb'
  cookbook 'firewall'
  owner 'root'
  group 'root'
  mode '0755'
end

service 'firewall' do
  supports restart: true, start: true, stop: true
  action :enable
  subscribes :start, 'template[/etc/iptables.rules]', :delayed
end

create_firewall_template
