# This class configures the network interfaces of a node based on data from
# hiera.
class profile::baseconfig::networking {
  # Configure interfaces as instructed in hiera.
  $if_to_configure = hiera('profile::interfaces', false)
  if($if_to_configure) {
    profile::baseconfig::configureinterface { $if_to_configure: }
  }

  # Trust ICMP redirects. This is sage as long as the secure_redirect is set
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
