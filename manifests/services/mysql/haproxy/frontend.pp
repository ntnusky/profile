# Configures the haproxy in frontend for the mysql cluster 
class profile::services::mysql::haproxy::frontend {
  require ::profile::services::haproxy
  include ::profile::services::mysql::firewall::balancer

  $ipv4 = hiera('profile::haproxy::management::ip')
  $ipv6 = hiera('profile::haproxy::management::ipv6', false)

  if($ipv6) {
    haproxy::listen { 'mysqlcluster':
      bind => {
        "${ipv4}:3306" => [],
        "${ipv6}:3306" => [],
      },
      mode => 'tcp',
    }
  } else {
    haproxy::listen { 'mysqlcluster':
      ipaddress => $ipv4,
      ports     => '3306',
      mode      => 'tcp',
    }
  }
}
