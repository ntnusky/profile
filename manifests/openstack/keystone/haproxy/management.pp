# Configures the haproxy frontend for the internal and admin keystone API
class profile::openstack::keystone::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::profile::openstack::keystone::firewall::haproxy::management
  include ::profile::openstack::keystone::haproxy::backend::oldmanagement

  $ipv4 = hiera('profile::haproxy::management::ipv4')
  $ipv6 = hiera('profile::haproxy::management::ipv6', false)
  $certificate = hiera('profile::haproxy::services::apicert::certfile', false)
  $certfile = hiera('profile::haproxy::services::apicert::certfile',
                    '/etc/ssl/private/haproxy.servicesapi.pem')

  if($certificate) {
    $ssl = ['ssl', 'crt', $certfile]
  } else {
    $ssl = []
  }

  if($ipv6) {
    $bind_adm => { 
      "${ipv4}:35357" => $ssl,
      "${ipv6}:35357" => $ssl,
    }
    $bind_int => { 
      "${ipv4}:5000" => $ssl,
      "${ipv6}:5000" => $ssl,
    }
  } else {
    $bind_adm => { 
      "${ipv4}:35357" => $ssl,
    }
    $bind_int => { 
      "${ipv4}:5000" => $ssl,
    }
  }

  $ft_admin_options = {
    'default_backend' => 'bk_keystone_admin',
  }
  $ft_internal_options = {
    'default_backend' => 'bk_keystone_internal',
  }

  haproxy::frontend { 'ft_keystone_admin':
    bind    => $bind_adm,
    mode    => 'http',
    options => $ft_admin_options,
  }
  haproxy::frontend { 'ft_keystone_internal':
    bind    => $bind_int,
    mode    => 'http',
    options => $ft_internal_options,
  }

  $backend_options = {
    'balance' => 'source',
    'option'  => [
      'tcplog',
      'tcpka',
      'httpchk',
    ],
  }

  haproxy::backend { 'bk_keystone_admin':
    mode    => 'http',
    options => $backend_options,
  }

  haproxy::backend { 'bk_keystone_internal':
    mode    => 'http',
    options => $backend_options,
  }
}
