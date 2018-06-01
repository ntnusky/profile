# Configures the firewall to accept incoming traffic to nova-compute
# And underlying services
class profile::openstack::nova::firewall::compute {
  $management_v4 = hiera('profile::networks::management::ipv4::prefix')
  $management_v6 = hiera('profile::networks::management::ipv6::prefix')
  $extra_net = hiera('profile::networks::management::ipv4::prefix::extra',
      false)

  require ::profile::baseconfig::firewall

  firewall { '500 accept nova-vnc':
    source => $management_v4,
    proto  => 'tcp',
    dport  => '5900-5999',
    action => 'accept',
  }
  firewall { '500 ipv6 accept nova-vnc':
    source   => $management_v6,
    proto    => 'tcp',
    dport    => '5900-5999',
    action   => 'accept',
    provider => 'ip6tables',
  }
  firewall { '501 accept live migration':
    source => $management_v4,
    proto  => 'tcp',
    dport  => '16509',
    action => 'accept',
  }
  firewall { '501 ipv6 accept live migration':
    source   => $management_v6,
    proto    => 'tcp',
    dport    => '16509',
    action   => 'accept',
    provider => 'ip6tables',
  }
  firewall { '502 accept live migration data stream':
    source => $management_v4,
    proto  => 'tcp',
    dport  => '49152-49261',
    action => 'accept',
  }
  firewall { '502 ipv6 accept live migration data stream':
    source   => $management_v6,
    proto    => 'tcp',
    dport    => '49152-49261',
    action   => 'accept',
    provider => 'ip6tables',
  }
  if($extra_net) {
    firewall { '503 accept live migration':
      source => $extra_net,
      proto  => 'tcp',
      dport  => '16509',
      action => 'accept',
    }
    firewall { '503 accept live migration data stream':
      source => $management_v4,
      proto  => 'tcp',
      dport  => '49152-49261',
      action => 'accept',
    }
  }
}
