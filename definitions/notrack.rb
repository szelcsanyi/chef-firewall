define :firewall_notrack, proto: 'tcp',
                          port: '',
                          protoversion: 'ipv4'  do

  unless Chef::Config['solo']
    proto        = params[:proto]
    protoversion = params[:protoversion]
    port         = params[:port]
    comment      = params[:name]

    firewall_rule comment do
      rule "--dport #{port}"
      proto proto
      protoversion protoversion
      jump 'NOTRACK'
      chain 'PREROUTING'
      table 'raw'
    end

    firewall_rule comment do
      rule "--sport #{port}"
      proto proto
      protoversion protoversion
      jump 'NOTRACK'
      chain 'OUTPUT'
      table 'raw'
    end
  end

end
