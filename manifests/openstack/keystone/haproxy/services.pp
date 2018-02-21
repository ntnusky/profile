# Configures the haproxy frontend for the public keystone API
class profile::openstack::keystone::haproxy::services {
  require ::profile::services::haproxy
  include ::profile::openstack::keepalive::firewall::haproxy::services 

  $ipv4 = hiera('profile::haproxy::services::ipv4')
  $ipv6 = hiera('profile::haproxy::services::ipv6', false)

  $ft_options = {
    'default_backend' => 'bk_keystone_public',
  }

  if($ipv6) {
    haproxy::frontend { 'ft_keystone_public':
      bind    => {
        "${ipv4}:5000" => [],
        "${ipv6}:5000" => [],
      },
      mode    => 'tcp',
      options => $ft_options,
    }
  } else {
    haproxy::frontend { 'ft_keystone_public':
      ipaddress => $ipv4,
      ports     => '5000',
      mode      => 'tcp',
      options   => $ft_options,
    }
  }

  haproxy::backend { 'bk_keystone_public':
    mode    => 'tcp',
    options => {
      'balance' => 'source',
      'option'  => [
        'tcplog',
        'tcpka',
        'httpchk',
      ],
    },
  }
}
