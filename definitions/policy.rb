define :L7_firewall_policy, policy: 'ACCEPT',
                            table: 'filter',
                            chain: 'INPUT',
                            protoversion: 'ipv4' do
  unless Chef::Config['solo']
    t = create_firewall_template

    table        = params[:table]
    chain        = params[:chain].upcase
    protoversion = params[:protoversion]
    policy       = params[:policy].upcase

    t.variables[:parameters][protoversion][table][chain][:policy] = policy
  end
end
