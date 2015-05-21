class profile::corosync {
  class { '::corosync':
    enable_secauth    => true,
    authkey           => '/var/lib/puppet/ssl/certs/ca.pem',
    bind_address      => $ipaddress_eth1,
    multicast_address => '239.1.1.2',
  }
  ::corosync::service { 'pacemaker':
    version => '0',
  }
}
