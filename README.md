# firewall cookbook
[![Build Status](https://travis-ci.org/szelcsanyi/chef-firewall.svg?branch=master)](https://travis-ci.org/szelcsanyi/chef-firewall)
[![security](https://hakiri.io/github/szelcsanyi/chef-firewall/master.svg)](https://hakiri.io/github/szelcsanyi/chef-firewall/master)

## Description

Configures [iptables](http://en.wikipedia.org/wiki/Iptables) packet filter via Opscode Chef in /etc/iptables.rules

## Supported Platforms

* Ubuntu
* Debian

## Tested on

* Ubuntu 12.04, 14.04
* Debian 7

## Recipes

* `firewall` - The default recipe.
* `firewall::allow_ssh` - allows ssh on port 22
* `firewall::basic_firewall` - sets up a basic firewall rule and chain set with default drop policy
* `firewall::basic_firewall_ipv6` - same as basic_firewall but for ipv6

## Usage

### Policy
* table: iptables table. (default: filter)
* chain: iptables chain. (default: INPUT)
* protoversion: ipv4 or ipv6. (default: ipv4)
* policy: iptables policy. (default: ACCEPT)

```ruby
firewall_policy 'Drop input' do
  policy 'DROP'
  chain 'INPUT'
end
```

### Notrack
* proto: protocol. (default: tcp)
* protoversion: ipv4 or ipv6. (default: ipv4)
* port: tcp or udp port. (default: '')

```ruby
firewall_notrack "Do not track http traffic" do
  port "80"
end
```

### Rule
* rule: iptables rule. (default: '')
* position: position in the rule list. (default: APPEND)
* table: iptables table. (default: filter)
* chain: iptables chain. (default: INPUT)
* proto: protocol. (default: all)
* protoversion: ipv4 or ipv6. (default: ipv4)
* jump: where to jump, like -j. (default: ACCEPT)
* enabled: boolean. (default: true)

Example disabled rule to drop all traffic from 1.2.3.4 in blacklist chain:
```ruby
firewall_rule 'Example blacklist rule' do
  rule '-s 1.2.3.4'
  jump 'DROP'
  chain 'BLACKLIST'
  enabled false
end
```

## TODO
* Rewrite to LWRP

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

* Freely distributable and licensed under the [MIT license](http://szelcsanyi.mit-license.org/2015/license.html).
* Copyright (c) 2015 Gabor Szelcsanyi

[![image](https://ga-beacon.appspot.com/UA-56493884-1/chef-firewall/README.md)](https://github.com/szelcsanyi/chef-firewall)

