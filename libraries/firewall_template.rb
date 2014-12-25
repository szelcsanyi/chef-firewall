# The firewall template
module FirewallTemplate
  def create_firewall_template
    t = nil
    begin
      t = resources(template: '/etc/iptables.rules')
    rescue Chef::Exceptions::ResourceNotFound
      t = template '/etc/iptables.rules' do
        mode '0755'
        owner 'root'
        group 'root'
        source 'etc/iptables.rules.erb'
        cookbook 'firewall'
        variables(parameters: Hash.new do
          |h, k| h[k] = Hash.new(&h.default_proc)
        end)
      end
    end
    t
  end
end
