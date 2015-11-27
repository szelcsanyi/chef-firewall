define :L7_firewall_notrack, proto: 'tcp',
                             port: '',
                             protoversion: 'ipv4' do
  unless Chef::Config['solo']
    proto        = params[:proto]
    protoversion = params[:protoversion]
    port         = params[:port]
    comment      = params[:name]

    case node[:kernel][:release].split('.')[0]
    when '3', '4'
      jump = 'CT --notrack'
    when '2'
      jump = 'NOTRACK'
    else
      raise Chef::Exceptions::ValidationFailed, 'Unknown kernel version!'
    end

    L7_firewall_rule comment do
      rule "--dport #{port}"
      proto proto
      protoversion protoversion
      jump jump
      chain 'PREROUTING'
      table 'raw'
    end

    L7_firewall_rule comment do
      rule "--sport #{port}"
      proto proto
      protoversion protoversion
      jump jump
      chain 'OUTPUT'
      table 'raw'
    end
  end
end
