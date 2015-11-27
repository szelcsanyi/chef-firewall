#
# Cookbook Name:: L7-firewall
# Recipe:: get_ips
#
# Copyright 2015, Gabor Szelcsanyi <szelcsanyi.gabor@gmail.com>


public_ipaddress = IPFinder.find_one(node, :public_ipv4)
node.default['public_ipaddress'] = (public_ipaddress.nil?) ? '' :  public_ipaddress[:addr]
Chef::Log.info "Public IPv4: \e[1;32m#{node.default['public_ipaddress']}\e[0m"

public_ip6address = IPFinder.find_one(node, :public_ipv6)
node.default['public_ip6address'] = (public_ip6address.nil?) ? '' : public_ip6address[:addr]
Chef::Log.info "Public IPv6: \e[1;32m#{node.default['public_ip6address']}\e[0m"
