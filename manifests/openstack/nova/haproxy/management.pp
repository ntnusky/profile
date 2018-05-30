# Configures the haproxy frontend for the internal and admin nova API
class profile::openstack::nova::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::profile::openstack::nova::firewall::haproxy
  include ::profile::openstack::nova::haproxy::backend::oldmanagement

  $ipv4 = hiera('profile::haproxy::management::ipv4')
  $ipv6 = hiera('profile::haproxy::management::ipv6', false)
  $certificate = hiera('profile::haproxy::management::apicert', false)
  $certfile = hiera('profile::haproxy::services::management::certfile',
                    '/etc/ssl/private/haproxy.managementapi.pem')

  if($certificate) {
    $ssl = ['ssl', 'crt', $certfile]
    $proto = 'X-Forwarded-Proto:\ https'
  } else {
    $ssl = []
    $proto = 'X-Forwarded-Proto:\ http'
  }

  if($ipv6) {
    $bind_api = {
      "${ipv4}:8774" => $ssl,
      "${ipv6}:8774" => $ssl,
    }
    $bind_metadata = {
      "${ipv4}:8775" => [],
      "${ipv6}:8775" => [],
    }
    $bind_place = {
      "${ipv4}:8778" => $ssl,
      "${ipv6}:8778" => $ssl,
    }
  } else {
    $bind_api = {
      "${ipv4}:8774" => $ssl,
    }
    $bind_metadata = {
      "${ipv4}:8775" => [],
    }
    $bind_place = {
      "${ipv4}:8778" => $ssl,
    }
  }

  $ft_api_options = {
    'default_backend' => 'bk_nova_api_admin',
    'reqadd'          => $proto,
  }
  $ft_metadata_options = {
    'default_backend' => 'bk_nova_metadata',
    'reqadd'          => 'X-Forwarded-Proto:\ http',
  }
  $ft_place_options = {
    'default_backend' => 'bk_nova_place_admin',
    'reqadd'          => $proto,
  }

  haproxy::frontend { 'ft_nova_api_admin':
    bind    => $bind_api,
    mode    => 'http',
    options => $ft_api_options,
  }
  haproxy::frontend { 'ft_nova_metadata':
    bind    => $bind_metadata,
    mode    => 'http',
    options => $ft_metadata_options,
  }
  haproxy::frontend { 'ft_nova_place_admin':
    bind    => $bind_place,
    mode    => 'http',
    options => $ft_place_options,
  }

  $backend_options = {
    'balance' => 'source',
    'option'  => [
      'tcplog',
      'tcpka',
      'httpchk',
    ],
  }

  haproxy::backend { 'bk_nova_api_admin':
    mode    => 'http',
    options => $backend_options,
  }
  haproxy::backend { 'bk_nova_metadata':
    mode    => 'http',
    options => {
      'balance' => 'source',
      'option'  => [
        'tcplog',
        'tcpka',
      ]
    },
  }
  haproxy::backend { 'bk_nova_place_admin':
    mode    => 'http',
    options => $backend_options,
  }
}
