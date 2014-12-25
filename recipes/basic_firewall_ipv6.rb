unless IPFinder.find(node, :public_ipv6).empty? && IPFinder.find(node, :private_ipv6).empty?

  firewall_rule 'Example whitelist for ipv6' do
    rule '--dport 123'
    proto 'tcp'
    jump 'ACCEPT'
    chain 'WHITELIST'
    enabled false
    protoversion 'ipv6'
  end

  firewall_rule 'Example blacklist for ipv6' do
    rule '--dport 123'
    proto 'tcp'
    jump 'DROP'
    chain 'BLACKLIST'
    enabled false
    protoversion 'ipv6'
  end

  firewall_rule 'Allow icmp echo request' do
    rule '--icmp-type echo-request'
    proto 'icmpv6'
    jump 'ACCEPT'
    chain 'ALLOWED'
    protoversion 'ipv6'
  end

  firewall_rule 'Check for whitelist on external interface' do
    jump 'WHITELIST'
    chain 'PUBLIC'
    protoversion 'ipv6'
  end

  firewall_rule 'Check for blacklist' do
    jump 'BLACKLIST'
    chain 'PUBLIC'
    protoversion 'ipv6'
  end

  firewall_rule 'Allow established connections' do
    rule '-m state --state RELATED,ESTABLISHED'
    jump 'ACCEPT'
    chain 'PUBLIC'
    protoversion 'ipv6'
  end

  firewall_rule 'Allow allowed packets' do
    jump 'ALLOWED'
    chain 'PUBLIC'
    protoversion 'ipv6'
  end

  firewall_rule 'Allow all packets on private intrfaces' do
    jump 'ACCEPT'
    chain 'PRIVATE'
    protoversion 'ipv6'
  end

  firewall_rule 'Allow from looback' do
    rule '-i lo'
    jump 'ACCEPT'
    chain 'INPUT'
    protoversion 'ipv6'
  end

  IPFinder.find(node, :private_ipv6).collect { |addr| addr[:iface].split(':')[0] }.uniq.each do |iface|
    firewall_rule 'Check packets on private interface' do
      rule "-i #{iface}"
      jump 'PRIVATE'
      chain 'INPUT'
      protoversion 'ipv6'
    end
  end

  IPFinder.find(node, :public_ipv6).collect { |addr| addr[:iface].split(':')[0] }.uniq.each do |iface|
    firewall_rule 'Check packets on public interface' do
      rule "-i #{iface}"
      jump 'PUBLIC'
      chain 'INPUT'
      protoversion 'ipv6'
    end
  end

  firewall_policy 'Drop input' do
    policy 'DROP'
    chain 'INPUT'
    protoversion 'ipv6'
  end

  firewall_policy 'Drop forward' do
    policy 'DROP'
    chain 'FORWARD'
    protoversion 'ipv6'
  end
end

case node['kernel']['release'].split('.')[0]
when '3'
  firewall_rule 'dont track local traffic' do
    rule '-i lo'
    jump 'CT --notrack'
    chain 'PREROUTING'
    table 'raw'
    protoversion 'ipv6'
  end

  firewall_rule 'dont track local traffic' do
    rule '-o lo'
    jump 'CT --notrack'
    chain 'OUTPUT'
    table 'raw'
    protoversion 'ipv6'
  end
when '2'
  firewall_rule 'dont track local traffic' do
    rule '-i lo'
    jump 'NOTRACK'
    chain 'PREROUTING'
    table 'raw'
    protoversion 'ipv6'
  end

  firewall_rule 'dont track local traffic' do
    rule '-o lo'
    jump 'NOTRACK'
    chain 'OUTPUT'
    table 'raw'
    protoversion 'ipv6'
  end
end