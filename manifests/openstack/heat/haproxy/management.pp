# Configures the haproxy frontend for the internal and admin heat API
class profile::openstack::heat::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::profile::openstack::heat::firewall::haproxy
  include ::profile::openstack::heat::haproxy::backend::oldmanagement

  $ipv4 = hiera('profile::haproxy::management::ipv4')
  $ipv6 = hiera('profile::haproxy::management::ipv6', false)
  $certificate = hiera('profile::haproxy::management::apicert', false)
  $certfile = hiera('profile::haproxy::services::management::certfile',
                    '/etc/ssl/private/haproxy.managementapi.pem')

  if($certificate) {
    $ssl = ['ssl', 'crt', $certfile]
  } else {
    $ssl = []
  }

  if($ipv6) {
    $bind_api = {
      "${ipv4}:8004" => $ssl,
      "${ipv6}:8004" => $ssl,
    }
    $bind_cfn = {
      "${ipv4}:8000" => $ssl,
      "${ipv6}:8000" => $ssl,
    }
  } else {
    $bind_api = {
      "${ipv4}:8004" => $ssl,
    }
    $bind_cfn = {
      "${ipv4}:8000" => $ssl,
    }
  }

  $ft_api_options = {
    'default_backend' => 'bk_heat_api_admin',
  }
  $ft_cfn_options = {
    'default_backend' => 'bk_heat_cfn_admin',
  }

  haproxy::frontend { 'ft_heat_api_admin':
    bind    => $bind_api,
    mode    => 'http',
    options => $ft_api_options,
  }
  haproxy::frontend { 'ft_heat_cfn_admin':
    bind    => $bind_cfn,
    mode    => 'http',
    options => $ft_cfn_options,
  }

  $backend_options = {
    'balance' => 'source',
    'option'  => [
      'tcplog',
      'tcpka',
      'httpchk',
    ],
  }

  haproxy::backend { 'bk_heat_api_admin':
    mode    => 'http',
    options => $backend_options,
  }
  haproxy::backend { 'bk_heat_cfn_admin':
    mode    => 'http',
    options => $backend_options,
  }
}
