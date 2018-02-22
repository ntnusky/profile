# Configures the haproxy frontend for the internal and admin glance API and the
# glance registry
class profile::openstack::glance::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::profile::openstack::glance::firewall::haproxy::api
  include ::profile::openstack::glance::firewall::haproxy::registry
  include ::profile::openstack::glance::haproxy::backend::oldmanagement

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
      "${ipv4}:9292" => $ssl,
      "${ipv6}:9292" => $ssl,
    }
    $bind_reg = {
      "${ipv4}:9191" => $ssl,
      "${ipv6}:9191" => $ssl,
    }
  } else {
    $bind_api = {
      "${ipv4}:9292" => $ssl,
    }
    $bind_reg = {
      "${ipv4}:9191" => $ssl,
    }
  }

  $ft_api_options = {
    'default_backend' => 'bk_glance_api_admin',
  }
  $ft_reg_options = {
    'default_backend' => 'bk_glance_registry',
  }

  haproxy::frontend { 'ft_glance_api_admin':
    bind    => $bind_api,
    mode    => 'http',
    options => $ft_api_options,
  }
  haproxy::frontend { 'ft_glance_registry':
    bind    => $bind_reg,
    mode    => 'http',
    options => $ft_reg_options,
  }

  $backend_options = {
    'balance' => 'source',
    'option'  => [
      'tcplog',
      'tcpka',
      'httpchk',
    ],
  }
  $backend_reg_options = {
    'balance' => 'source',
    'option'  => [
      'tcplog',
      'tcpka',
    ],
  }

  haproxy::backend { 'bk_glance_api_admin':
    mode    => 'http',
    options => $backend_options,
  }

  haproxy::backend { 'bk_glance_registry':
    mode    => 'http',
    options => $backend_reg_options,
  }
}
