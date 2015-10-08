#
# Cookbook Name:: L7-firewall
# Recipe:: basic_firewall
#
# Copyright 2015, Gabor Szelcsanyi <szelcsanyi.gabor@gmail.com>

unless IPFinder.find(node, :public_ipv4).empty?

  L7_firewall_rule 'log bad flagged packages' do
    jump 'LOG --log-prefix "BADFLAGS: "'
    chain 'BADFLAGS'
    enabled false
  end

  L7_firewall_rule 'drop bad flagged packages' do
    jump 'DROP'
    chain 'BADFLAGS'
  end

  ['ACK,FIN FIN', 'ACK,PSH PSH', 'ACK,URG URG', 'FIN,RST FIN,RST', 'SYN,FIN SYN,FIN',
   'SYN,RST SYN,RST', 'ALL ALL', 'ALL NONE', 'ALL FIN,PSH,URG', 'ALL SYN,FIN,PSH,URG',
   'ALL SYN,RST,ACK,FIN,URG'].each do |flag|
    L7_firewall_rule 'badflag' do
      rule "--tcp-flags #{flag}"
      proto 'tcp'
      jump 'BADFLAGS'
      chain 'TCP_FLAGS'
    end
  end

  L7_firewall_rule 'Example whitelist' do
    rule '-s 1.2.3.4'
    jump 'ACCEPT'
    chain 'WHITELIST'
    enabled false
  end

  L7_firewall_rule 'Example blacklist' do
    rule '-s 1.2.3.4'
    jump 'DROP'
    chain 'BLACKLIST'
    enabled false
  end

  L7_firewall_rule 'Allow icmp echo request' do
    rule '--icmp-type echo-request'
    proto 'icmp'
    jump 'ACCEPT'
    chain 'ALLOWED'
  end

  L7_firewall_rule 'Allow icmp time exceeded' do
    rule '--icmp-type time-exceeded'
    proto 'icmp'
    jump 'ACCEPT'
    chain 'ALLOWED'
  end

  L7_firewall_rule 'Allow icmp fragmentation needed' do
    rule '--icmp-type fragmentation-needed'
    proto 'icmp'
    jump 'ACCEPT'
    chain 'ALLOWED'
  end

  L7_firewall_rule 'Check for whitelist on external interface' do
    jump 'WHITELIST'
    chain 'PUBLIC'
  end

  L7_firewall_rule 'Check for blacklist' do
    jump 'BLACKLIST'
    chain 'PUBLIC'
  end

  L7_firewall_rule 'Check for tcp flags' do
    jump 'TCP_FLAGS'
    chain 'PUBLIC'
  end

  # reply something for traceroute probes
  L7_firewall_rule 'Traceroute udp packets' do
    rule '--dport 33434:33523'
    proto 'udp'
    jump 'REJECT'
    chain 'PUBLIC'
  end

  L7_firewall_rule 'Allow established connections' do
    rule '-m state --state RELATED,ESTABLISHED'
    jump 'ACCEPT'
    chain 'PUBLIC'
  end

  L7_firewall_rule 'Allow allowed packets' do
    jump 'ALLOWED'
    chain 'PUBLIC'
  end

  L7_firewall_rule 'Allow all packets on private intrfaces' do
    jump 'ACCEPT'
    chain 'PRIVATE'
  end

  L7_firewall_rule 'Allow from looback' do
    rule '-i lo'
    jump 'ACCEPT'
    chain 'INPUT'
  end

  IPFinder.find(node, :private_ipv4).map { |addr| addr[:iface].split(':')[0] }.uniq.each do |iface|
    L7_firewall_rule 'Check packets on private interface' do
      rule "-i #{iface}"
      jump 'PRIVATE'
      chain 'INPUT'
    end
  end

  IPFinder.find(node, :public_ipv4).map { |addr| addr[:iface].split(':')[0] }.uniq.each do |iface|
    L7_firewall_rule 'Check packets on public interface' do
      rule "-i #{iface}"
      jump 'PUBLIC'
      chain 'INPUT'
    end
  end

  L7_firewall_rule 'Allow established connections in forward' do
    rule '-m state --state RELATED,ESTABLISHED'
    jump 'ACCEPT'
    chain 'FORWARD'
  end

  L7_firewall_policy 'Drop input' do
    policy 'DROP'
    chain 'INPUT'
  end

  L7_firewall_policy 'Drop forward' do
    policy 'DROP'
    chain 'FORWARD'
  end

end

case node['kernel']['release'].split('.')[0]
when '3'
  L7_firewall_rule 'dont track local traffic' do
    rule '-i lo'
    jump 'CT --notrack'
    chain 'PREROUTING'
    table 'raw'
  end

  L7_firewall_rule 'dont track local traffic' do
    rule '-o lo'
    jump 'CT --notrack'
    chain 'OUTPUT'
    table 'raw'
  end
when '2'
  L7_firewall_rule 'dont track local traffic' do
    rule '-i lo'
    jump 'NOTRACK'
    chain 'PREROUTING'
    table 'raw'
  end

  L7_firewall_rule 'dont track local traffic' do
    rule '-o lo'
    jump 'NOTRACK'
    chain 'OUTPUT'
    table 'raw'
  end
end
