# This definition collects interface configuration from hiera, and configures
# the interface according to these settings.
define setDHCP {
  $method = hiera("profile::interfaces::${name}::method")
  $address = hiera("profile::interfaces::${name}::address", false)
  $netmask = hiera("profile::interfaces::${name}::netmask", '255.255.255.0')

  $mysql_master = hiera('profile::mysqlcluster::master')

  network::interface{ $name:
    method  => $method,
    address => $address,
    netmask => $netmask,
  }
}

# This class configures the network interfaces of a node based on data from
# hiera.
class profile::baseconfig::networking {
  # Configure interfaces as instructed in hiera.
  $interfacesToConfigure = hiera('profile::interfaces', false)
  if($interfacesToConfigure) {
    setDHCP { $interfacesToConfigure: }
  }

  # Disable the rp filter, as the return traffic ofthen arrives on another
  # interface than where the default gateway lives due to many interfaces on the
  # nodes.
  sysctl::value { 'net.ipv4.conf.all.rp_filter':
    value => "0",
  }
  sysctl::value { 'net.ipv4.conf.default.rp_filter':
    value => "0",
  }
}
