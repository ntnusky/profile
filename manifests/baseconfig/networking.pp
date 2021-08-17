# This class configures the network interfaces of a node based on data from
# hiera.
class profile::baseconfig::networking {
  # Configure interfaces as instructed in hiera.
  $if_to_configure = lookup('profile::baseconfig::network::interfaces', {
    'default_value' => false,
    'value_type'    => Variant[Hash,Boolean],
  })
  if($if_to_configure) {
    $os = $facts['operatingsystem']
    $distro = $facts['os']['release']['major']
    if($os == 'Ubuntu' and $distro != '16.04') {
      class { '::profile::baseconfig::network::netplan':
        nics => $if_to_configure,
      }
    }
    # TODO: The 16.04 logic is present to ensure that existing
    # 16.04 don't fail their puppet-run before they're reinstalled
    # Delete when you've got rid of them
    elsif ($os == 'CentOS' or $distro == '16.04') {
      class { '::profile::baseconfig::network::ifupdown':
        nics => $if_to_configure,
      }
    }
  }

  # Configure ovs-bridges as instructed in hiera
  $bridges = lookup('profile::baseconfig::network::bridges', {
    'value_type'    => Hash[String, Hash],
    'default_value' => {},
  })
  $bridges.each | $name, $configuration | {
    # Create a bridge
    ::profile::infrastructure::ovs::bridge { $name :
      mtu => $configuration['mtu'],
    }

    # If the bridge should have an external connection
    if($configuration['external']) {
      if($configuration['external']['mtu']) {
        $mtu = $configuration['external']['mtu']
      } else {
        $mtu = 1500
      }
      if($configuration['external']['driver']) {
        $driver = $configuration['external']['driver']
      } else {
        $driver = ''
      }

      # The connection might be a bond consisting of multiple physical
      # interfaces:
      if($configuration['external']['type'] == 'bond') {
        ::profile::infrastructure::ovs::port::bond {
            $configuration['external']['name']:
          bridge  => $name,
          members => $configuration['external']['members'],
          mtu     => $mtu,
        }
      }
      # The connection might be a single interface
      if($configuration['external']['type'] == 'interface') {
        ::profile::infrastructure::ovs::port::interface {
            $configuration['external']['name']:
          bridge => $name,
          driver => $driver,
          mtu    => $mtu,
        }
      }
      # The connection might be a patch connected to a certain VLAN of another
      # ovs-bridge.
      if($configuration['external']['type'] == 'vlan-patch') {
        ::profile::infrastructure::ovs::patch::vlan {"${name}-vlan-patch":
          source_bridge      => $configuration['external']['bridge'],
          source_vlan        => $configuration['external']['vlan'],
          destination_bridge => $name,
        }
      }
    }
  }

  # Trust ICMP redirects. This is safe as long as the secure_redirect is set
  # because the host would then only trust redirects from hosts acting as a
  # gateway.
  sysctl::value { 'net.ipv4.conf.all.accept_redirects':
    value => '1',
  }
  sysctl::value { 'net.ipv6.conf.all.accept_redirects':
    value => '1',
  }

  # Disable the rpfilter if that is desirable. This is needed if we are not
  # using multiple routing-tables on hosts where there is more than one nic.
  $rp_filter = hiera('profile::networking::rpfilter', false)
  if(! $rp_filter) {
    # Disable the rp filter, as the return traffic ofthen arrives on another
    # interface than where the default gateway lives due to many interfaces on the
    # nodes.
    sysctl::value { 'net.ipv4.conf.all.rp_filter':
      value => '0',
    }
    sysctl::value { 'net.ipv4.conf.default.rp_filter':
      value => '0',
    }
  }
}
