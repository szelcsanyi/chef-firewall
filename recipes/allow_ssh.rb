# For ipv4
firewall_rule 'SSH limit' do
  rule '-m recent --set --name SSH'
  proto 'tcp'
  jump 'LOG --log-prefix "SSH Attempt: "'
  chain 'SSH'
end

firewall_rule 'SSH limit drop' do
  rule '-m recent --update --seconds 120 --hitcount 5 --name SSH'
  proto 'tcp'
  jump 'DROP'
  chain 'SSH'
end

firewall_rule 'Allow ssh access' do
  rule '--dport 22 -m state --state NEW'
  proto 'tcp'
  jump 'SSH'
  chain 'ALLOWED'
end

# For ipv6
firewall_rule 'SSH limit' do
  rule '-m recent --set --name SSH'
  proto 'tcp'
  jump 'LOG --log-prefix "SSH Attempt: "'
  chain 'SSH'
  protoversion 'ipv6'
end

firewall_rule 'SSH limit drop' do
  rule '-m recent --update --seconds 120 --hitcount 5 --name SSH'
  proto 'tcp'
  jump 'DROP'
  chain 'SSH'
  protoversion 'ipv6'
end

firewall_rule 'Allow ssh access' do
  rule '--dport 22'
  proto 'tcp'
  jump 'SSH'
  chain 'ALLOWED'
  protoversion 'ipv6'
end
