# This class configures the network interfaces of a node based on data from
# hiera.
class profile::baseconfig::networking {
  # Configure interfaces as instructed in hiera.
  $if_to_configure = hiera('profile::interfaces', false)
  if($if_to_configure) {
    profile::baseconfig::configureinterface { $if_to_configure: }
  }

  # Add extra routes based on hieradata
  $routes = hiera_hash('profile::networking::routes', [])
  $routes.each | $network, $gateway | {
    $netid = ip_address($network)
    network::route { "RouteTo-${netid}":
      ipaddress => [$netid],
      netmask   => [ip_netmask($network)],
      gateway   => [$gateway],
    }
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
