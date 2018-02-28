# Configures the haproxy frontend for the internal and admin neutron API
class profile::openstack::neutron::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::profile::openstack::neutron::firewall::haproxy
  include ::profile::openstack::neutron::haproxy::backend::oldmanagement

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
      "${ipv4}:9696" => $ssl,
      "${ipv6}:9696" => $ssl,
    }
  } else {
    $bind_api = {
      "${ipv4}:9696" => $ssl,
    }
  }

  $ft_api_options = {
    'default_backend' => 'bk_neutron_api_admin',
  }

  haproxy::frontend { 'ft_neutron_api_admin':
    bind    => $bind_api,
    mode    => 'http',
    options => $ft_api_options,
  }

  $backend_options = {
    'balance' => 'source',
    'option'  => [
      'tcplog',
      'tcpka',
      'httpchk',
    ],
  }

  haproxy::backend { 'bk_neutron_api_admin':
    mode    => 'http',
    options => $backend_options,
  }
}