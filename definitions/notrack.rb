define :L7_firewall_notrack, proto: 'tcp',
                          port: '',
                          protoversion: 'ipv4'  do

  unless Chef::Config['solo']
    proto        = params[:proto]
    protoversion = params[:protoversion]
    port         = params[:port]
    comment      = params[:name]

    L7_firewall_rule comment do
      rule "--dport #{port}"
      proto proto
      protoversion protoversion
      jump 'CT --notrack'
      chain 'PREROUTING'
      table 'raw'
    end

    L7_firewall_rule comment do
      rule "--sport #{port}"
      proto proto
      protoversion protoversion
      jump 'CT --notrack'
      chain 'OUTPUT'
      table 'raw'
    end
  end

end
