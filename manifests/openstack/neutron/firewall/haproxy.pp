# Configures the firewall to accept incoming traffic to the neutron API. 
class profile::openstack::neutron::firewall::haproxy {
  require ::profile::baseconfig::firewall

  firewall { '500 accept IPv4 Neutron API':
    proto  => 'tcp',
    dport  => '9696',
    action => 'accept',
  }

  firewall { '500 accept IPv6 Neutron API':
    proto    => 'tcp',
    dport    => '9696',
    action   => 'accept',
    provider => 'ip6tables',
  }
}
