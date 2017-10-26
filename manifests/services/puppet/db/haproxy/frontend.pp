# Configures the haproxy in frontend for the puppetdb service 
class profile::services::puppet::db::haproxy::frontend {
  require ::profile::services::haproxy
  include ::profile::services::puppet::db::firewall

  $ipv4 = hiera('profile::haproxy::management::ip')
  $ipv6 = hiera('profile::haproxy::management::ipv6', false)

  if($ipv6) {
    haproxy::listen { 'puppetdb':
      bind      => {
        "${ipv4}:8081" => [],
        "${ipv6}:8081" => [],
      },
    }
  } else {
    haproxy::listen { 'puppetdb':
      ipaddress => $ipv4,
      ports     => '8081',
    }
  }
}
