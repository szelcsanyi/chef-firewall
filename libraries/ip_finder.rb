# Chef
class Chef
  # IPFinder
  module IPFinder
    extend self

    def find(node, scope)
      return unless load_ipaddr_extensions

      find_node_ips(node, scope)
    end

    def find_one(node, scope)
      find(node, scope).first
    end

    def find_by_interface(node, interface, scope = :ipv4)
      return unless load_ipaddr_extensions

      find_interface_ip(node, interface, normalize_scope(scope))
    end

    def ip_to_scope(ip)
      scopes = %w( node private public )
      ipaddr = IPAddr.new(ip)
      return scopes if ipaddr == IPAddr.new('0.0.0.0')

      scopes.find_all { |scope| in_scope?(ip, normalize_scope(scope)) }
    end

    def find_all(node, base_scope = 'ipv4')
      scopes = %w( node private public )

      scopes.each_with_object({}) do |result, scope|
        ips = self.find(node, [base_scope, scope].join('_'))
        result[scope] = ips unless ips.empty?
        result
      end
    end

    private

    def normalize_scope(scope)
      Array(scope).map do |item|
        item.to_s.gsub('public', 'global').gsub('local', 'private').gsub('node', 'loopback').split('_')
      end.flatten.uniq.sort
    end

    def in_scope?(address, scope)
      ipaddr = IPAddr.new(address)
      Array(scope).all? { |prop| ipaddr.send("#{prop}?".to_sym) }
    rescue
      false
    end

    def find_node_ips(node, scope)
      ips = []

      norm_scope = normalize_scope(scope)

      if node['network'] && node['network']['interfaces']
        node['network']['interfaces'].each do |ifce, attrs|
          next unless attrs['addresses']
          attrs['addresses'].each do |addr, _|
            ips << { addr: addr, iface: ifce } if in_scope?(addr, norm_scope)
          end
        end
      end

      ips
    end

    def find_interface_ip(node, interface, scope = nil)
      return unless node['network'] && node['network']['interfaces']
      interfaces = node['network']['interfaces']
      return unless interfaces[interface] && interfaces[interface]['addresses']

      addrs = interfaces[interface]['addresses'].keys
      if scope
        addrs.find { |addr| in_scope?(addr, scope) }
      else
        addrs.first
      end
    end

    def load_ipaddr_extensions
      return true if defined?(IPAddrExtensions)

      begin
        require 'ipaddr_extensions'
      rescue LoadError => e
        Chef::Log.error("Can't load gem ipaddr_extensions: #{e}")
        false
      end
    end
  end
end
