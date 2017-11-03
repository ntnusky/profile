# Configures the haproxy in frontend for the puppetmasters 
class profile::services::puppet::server::haproxy::frontend {
  require ::profile::services::haproxy
  include ::profile::services::puppet::server::firewall

  $ipv4 = hiera('profile::haproxy::management::ip')
  $ipv6 = hiera('profile::haproxy::management::ipv6', false)

  $ft_options = {
    'default_backend' => 'bk_puppetserver',
  }

  if($ipv6) {
    haproxy::frontend { 'ft_puppetserver':
      bind    => {
        "${ipv4}:8140" => [],
        "${ipv6}:8140" => [],
      },
      mode    => 'tcp',
      options => $ft_options,
    }
  } else {
    haproxy::frontend { 'ft_puppetserver':
      ipaddress => $ipv4,
      ports     => '8140',
      mode      => 'tcp',
      options   => $ft_options,
    }
  }
  hapoxy::backend { 'bk_puppetserver':
    mode    => 'tcp',
    options => {
      'balance' => 'roundrobin',
      'option'  => [
        'tcplog',
      ],
    },
  }
}
