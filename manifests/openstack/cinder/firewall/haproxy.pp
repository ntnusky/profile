# Configures the firewall to accept incoming traffic to the cinder API. 
class profile::openstack::cinder::firewall::haproxy {
  require ::profile::baseconfig::firewall

  firewall { '500 accept IPv4 Cinder API':
    proto  => 'tcp',
    dport  => '8776',
    action => 'accept',
  }

  firewall { '500 accept IPv6 Cinder API':
    proto    => 'tcp',
    dport    => '8776',
    action   => 'accept',
    provider => 'ip6tables',
  }
}
