#
# Cookbook Name:: L7-firewall
# Recipe:: basic_firewall_ipv6
#
# Copyright 2015, Gabor Szelcsanyi <szelcsanyi.gabor@gmail.com>

unless IPFinder.find(node, :public_ipv6).empty? && IPFinder.find(node, :private_ipv6).empty?

  L7_firewall_rule 'Example whitelist for ipv6' do
    rule '--dport 123'
    proto 'tcp'
    jump 'ACCEPT'
    chain 'WHITELIST'
    enabled false
    protoversion 'ipv6'
  end

  L7_firewall_rule 'Example blacklist for ipv6' do
    rule '--dport 123'
    proto 'tcp'
    jump 'DROP'
    chain 'BLACKLIST'
    enabled false
    protoversion 'ipv6'
  end

  %w(destination-unreachable packet-too-big time-exceeded parameter-problem echo-request echo-reply
     router-advertisement neighbor-solicitation neighbor-advertisement redirect).each do |icmptype|
    L7_firewall_rule 'Allow icmp echo request' do
      rule "--icmpv6-type #{icmptype}"
      proto 'icmpv6'
      jump 'ACCEPT'
      chain 'ALLOWED'
      protoversion 'ipv6'
    end
  end

  L7_firewall_rule 'Check for whitelist on external interface' do
    jump 'WHITELIST'
    chain 'PUBLIC'
    protoversion 'ipv6'
  end

  L7_firewall_rule 'Check for blacklist' do
    jump 'BLACKLIST'
    chain 'PUBLIC'
    protoversion 'ipv6'
  end

  L7_firewall_rule 'Allow established connections' do
    rule '-m state --state RELATED,ESTABLISHED'
    jump 'ACCEPT'
    chain 'PUBLIC'
    protoversion 'ipv6'
  end

  L7_firewall_rule 'Allow allowed packets' do
    jump 'ALLOWED'
    chain 'PUBLIC'
    protoversion 'ipv6'
  end

  L7_firewall_rule 'Allow all packets on private intrfaces' do
    jump 'ACCEPT'
    chain 'PRIVATE'
    protoversion 'ipv6'
  end

  L7_firewall_rule 'Allow from looback' do
    rule '-i lo'
    jump 'ACCEPT'
    chain 'INPUT'
    protoversion 'ipv6'
  end

  pub_ifaces = []
  IPFinder.find(node, :public_ipv6).map { |addr| addr[:iface].split(':')[0] }.uniq.each do |iface|
    L7_firewall_rule 'Check packets on public interface' do
      rule "-i #{iface}"
      jump 'PUBLIC'
      chain 'INPUT'
      protoversion 'ipv6'
    end
    pub_ifaces << iface
  end

  IPFinder.find(node, :private_ipv6).map { |addr| addr[:iface].split(':')[0] }.uniq.each do |iface|
    next if pub_ifaces.include?(iface)
    L7_firewall_rule 'Check packets on private interface' do
      rule "-i #{iface}"
      jump 'PRIVATE'
      chain 'INPUT'
      protoversion 'ipv6'
    end
  end

  L7_firewall_rule 'Allow established connections in forward' do
    rule '-m state --state RELATED,ESTABLISHED'
    jump 'ACCEPT'
    chain 'FORWARD'
    protoversion 'ipv6'
  end

  L7_firewall_policy 'Drop input' do
    policy 'DROP'
    chain 'INPUT'
    protoversion 'ipv6'
  end

  L7_firewall_policy 'Drop forward' do
    policy 'DROP'
    chain 'FORWARD'
    protoversion 'ipv6'
  end
end

case node['kernel']['release'].split('.')[0]
when '3', '4', '5'
  jump = 'CT --notrack'
when '2'
  jump = 'NOTRACK'
else
  fail Chef::Exceptions::ValidationFailed, 'Unknown kernel version!'
end

L7_firewall_rule 'dont track local traffic' do
  rule '-i lo'
  jump jump
  chain 'PREROUTING'
  table 'raw'
  protoversion 'ipv6'
end

L7_firewall_rule 'dont track local traffic' do
  rule '-o lo'
  jump jump
  chain 'OUTPUT'
  table 'raw'
  protoversion 'ipv6'
end
