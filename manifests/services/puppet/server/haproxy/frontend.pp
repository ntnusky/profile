# Configures the haproxy in frontend for the puppetmasters 
class profile::services::puppet::server::haproxy::frontend {
  require ::profile::services::haproxy
  include ::profile::services::puppet::server::firewall

  $ipv4 = hiera('profile::haproxy::management::ip')
  $ipv6 = hiera('profile::haproxy::management::ipv6', false)

  if($ipv6) {
    haproxy::listen { 'puppetserver':
      bind => {
        "${ipv4}:8140" => [],
        "${ipv6}:8140" => [],
      },
      mode => 'tcp',
    }
  } else {
    haproxy::listen { 'puppetserver':
      ipaddress => $ipv4,
      ports     => '8140',
      mode      => 'tcp',
    }
  }
}
