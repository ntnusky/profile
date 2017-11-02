# Haproxy config for uchiwa
class profile::sensu::uchiwa::haproxy {
  include ::profile::sensu::uchiwa::firewall
  require ::profile::services::haproxy

  $domain = hiera('profile::sensu::uchiwa::fqdn')
  $ipv4 = hiera('profile::haproxy::management::ip')
  $ipv6 = hiera('profile::haproxy::management::ipv6', false)
  $ft_options = {
    'acl'         => "host_uchiwa hdr_dom(host) -m dom ${domain}",
    'use_backend' => 'bk_uchiwa if host_uchiwa',
    'option'      => [
      'forwardfor',
      'http-server-close',
    ],
  }

  if($ipv6) {
    haproxy::frontend { 'ft_uchiwa':
      bind    => {
        "${ipv4}:80"  => [],
        "${ipv4}:443" => [],
        "${ipv6}:80"  => [],
        "${ipv6}:443" => [],
      },
      mode    => 'http',
      options => $ft_options,
    }
  } else {
    haproxy::frontend { 'ft_uchiwa':
      ipaddress => $ipv4,
      ports     => '80,443',
      mode      => 'http',
      options   => $ft_options,
    }
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
}
