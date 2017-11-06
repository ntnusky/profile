# Configures the haproxy in frontend for the puppetdb service
class profile::services::puppet::db::haproxy::frontend {
  require ::profile::services::haproxy
  include ::profile::services::puppet::db::firewall

  $ipv4 = hiera('profile::haproxy::management::ipv4')
  $ipv6 = hiera('profile::haproxy::management::ipv6', false)

  $ft_options = {
    'default_backend' => 'bk_puppetdb',
  }

  if($ipv6) {
    haproxy::frontend { 'ft_puppetdb':
      bind    => {
        "${ipv4}:8081" => [],
        "${ipv6}:8081" => [],
      },
      mode    => 'tcp',
      options => $ft_options,
    }
  } else {
    haproxy::frontend { 'ft_puppetdb':
      ipaddress => $ipv4,
      ports     => '8081',
      mode      => 'tcp',
      options   => $ft_options,
    }
  }
  haproxy::backend { 'bk_puppetdb':
    mode    => 'tcp',
    options => {
      'balance' => 'roundrobin',
      'option'  => [
        'tcplog',
      ],
    },
  }
}
