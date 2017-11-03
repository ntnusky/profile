# Configures the haproxy in frontend for the mysql cluster 
class profile::services::mysql::haproxy::frontend {
  require ::profile::services::haproxy
  include ::profile::services::mysql::firewall::balancer

  $ipv4 = hiera('profile::haproxy::management::ip')
  $ipv6 = hiera('profile::haproxy::management::ipv6', false)

  $ft_options = {
    'default_backend' => 'bk_mysqlcluster',
  }

  if($ipv6) {
    haproxy::frontend { 'ft_mysqlcluster':
      bind    => {
        "${ipv4}:3306" => [],
        "${ipv6}:3306" => [],
      },
      mode    => 'tcp',
      options => $ft_options,
    }
  } else {
    haproxy::frontend { 'ft_mysqlcluster':
      ipaddress => $ipv4,
      ports     => '3306',
      mode      => 'tcp',
      options   => $ft_options,
    }
  }

  haproxy::backend { 'bk_mysqlcluster':
    mode    => 'tcp',
    options => {
      'balance' => 'roundrobin',
      'option'  => [
        'tcplog',
      ],
    },
  }
}
