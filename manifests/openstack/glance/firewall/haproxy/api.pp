# Configures the firewall to accept incoming traffic to the glance API. 
class profile::openstack::glance::firewall::haproxy::api {
  require ::profile::baseconfig::firewall

  firewall { '500 accept IPv4 Glance API':
    proto  => 'tcp',
    dport  => '9292',
    action => 'accept',
  }

  firewall { '500 accept IPv6 Glance API':
    proto    => 'tcp',
    dport    => '9292',
    action   => 'accept',
    provider => 'ip6tables',
  }
}
