# Haproxy config for uchiwa
class profile::sensu::haproxy {
  require ::profile::services::haproxy

  $domain = hiera('profile::sensu::uchiwa::fqdn')

  haproxy::frontend { 'ft_uchiwa':
    ipaddress => '*',
    ports     => '80,443',
    mode      => 'http',
    options   => {
      'acl'         => "host_uchiwa hdr_dom(host) -m dom ${domain}",
      'use_backend' => 'bk_uchiwa if host_uchiwa',
      'option'      => [
        'forwardfor',
        'http-server-close',
      ],
    },
  }

  haproxy::backend { 'bk_uchiwa':
    mode    => 'http',
    options => {
      'balance' => 'source',
      'cookie'  => 'SERVERID insert indirect nocache',
      'option'  => [
        'httplog',
        'log-health-checks',
      ],
    },
  }

  firewall { '040 accept http':
    proto  => 'tcp',
    dport  => 80,
    action => 'accept',
  }
  firewall { '041 accept https':
    proto  => 'tcp',
    dport  => 443,
    action => 'accept',
  }
}
