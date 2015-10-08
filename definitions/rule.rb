define :L7_firewall_rule, rule: '',
                       position: 'APPEND',
                       table: 'filter',
                       chain: 'INPUT',
                       proto: 'all',
                       protoversion: 'ipv4',
                       jump: 'ACCEPT',
                       enabled: true  do

  unless Chef::Config['solo']
    t = create_firewall_template

    rule         = params[:rule]
    position     = params[:position]
    table        = params[:table]
    chain        = params[:chain].upcase
    proto        = params[:proto]
    protoversion = params[:protoversion]
    jump         = params[:jump]
    comment      = params[:name]
    enabled      = params[:enabled]

    if t.variables[:parameters][protoversion][table][chain][:rules].is_a?(Hash)
      t.variables[:parameters][protoversion][table][chain][:rules] = []
    end

    t.variables[:parameters][protoversion][table][chain][:rules] << {
      rule: rule,
      jump: jump,
      comment: comment,
      proto: proto,
      enabled: enabled,
      position: position
    }
  end

end
