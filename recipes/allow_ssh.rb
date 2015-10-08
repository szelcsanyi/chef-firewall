#
# Cookbook Name:: L7-firewall
# Recipe:: allow_ssh
#
# Copyright 2015, Gabor Szelcsanyi <szelcsanyi.gabor@gmail.com>

%w( ipv4 ipv6 ).each do |protoversion|
  # Set limit
  L7_firewall_rule 'SSH limit' do
    rule '-m recent --set --name SSH'
    proto 'tcp'
    jump 'LOG --log-prefix "SSH Attempt: "'
    chain 'SSH'
    protoversion protoversion
  end

  # Drop if overlimit
  L7_firewall_rule 'SSH limit drop' do
    rule '-m recent --update --seconds 120 --hitcount 5 --name SSH'
    proto 'tcp'
    jump 'DROP'
    chain 'SSH'
    protoversion protoversion
  end

  # Accept if under limit
  L7_firewall_rule 'SSH limit allow' do
    jump 'ACCEPT'
    chain 'SSH'
    protoversion protoversion
  end

  # Jump to check chain
  L7_firewall_rule 'Allow ssh access' do
    rule '--dport 22 -m state --state NEW'
    proto 'tcp'
    jump 'SSH'
    chain 'ALLOWED'
    protoversion protoversion
  end
end
