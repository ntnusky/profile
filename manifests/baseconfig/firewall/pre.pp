# This class installs and configures firewall pre.
class profile::baseconfig::firewall::pre {
  Firewall {
    require => undef,
  }

  $ipv4_management_nets = hiera_array('profile::networking::management::ipv4::prefixes', false)
  $ipv6_management_nets = hiera_array('profile::networking::management::ipv6::prefixes', false)

  # Default firewall rules
  firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 reject local traffic not on loopback interface':
    iniface     => '! lo',
    proto       => 'all',
    destination => '127.0.0.1/8',
    action      => 'reject',
  }->
  firewall { '003 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }

  if($ipv4_management_nets) {
    $ipv4_management_nets.each |$net| {
      firewall { "004 accept incoming SSH from ${net}":
        proto    => 'tcp',
        dport    => 22,
        source   => $net,
        action   => 'accept',
      }
    }
  } else {
    firewall { '004 accept incoming SSH':
      proto  => 'tcp',
      dport  => 22,
      action => 'accept',
    }
  }

  # Default firewall rules
  firewall { '000 ipv6 accept all icmp':
    proto    => 'ipv6-icmp',
    action   => 'accept',
    provider => 'ip6tables',
  }->
  firewall { '001 ipv6 accept all to lo interface':
    proto    => 'all',
    iniface  => 'lo',
    action   => 'accept',
    provider => 'ip6tables',
  }->
  firewall { '002 ipv6 allow link-local':
    proto    => 'all',
    source   => 'fe80::/10',
    action   => 'accept',
    provider => 'ip6tables',
  }->
  firewall { '003 ipv6 accept related established rules':
    proto    => 'all',
    state    => ['RELATED', 'ESTABLISHED'],
    action   => 'accept',
    provider => 'ip6tables',
  }

  if($ipv6_management_nets) {
    $ipv6_management_nets.each |$net| {
      firewall { "004 ipv6 accept incoming SSH from ${net}":
        proto    => 'tcp',
        dport    => 22,
        source   => $net,
        action   => 'accept',
        provider => 'ip6tables',
      }
    }
  } else {
    firewall { '004 accept incoming SSH':
      proto    => 'tcp',
      dport    => 22,
      action   => 'accept',
      provider => 'ip6tables',
    }
  }
}
