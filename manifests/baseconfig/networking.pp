# This class configures the network interfaces of a node based on data from
# hiera.
class profile::baseconfig::networking {
  # Configure interfaces as instructed in hiera.
  $interfacesToConfigure = hiera('profile::interfaces', false)
  if($interfacesToConfigure) {
    profile::baseconfig::configureinterface { $interfacesToConfigure: }
  }

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
