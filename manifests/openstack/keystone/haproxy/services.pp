# Configures the haproxy frontend for the public keystone API
class profile::openstack::keystone::haproxy::services {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::serviceapi

  include ::profile::openstack::keystone::firewall::haproxy::services
  include ::profile::openstack::keystone::haproxy::backend::oldpublic

  $ipv4 = hiera('profile::haproxy::services::ipv4')
  $ipv6 = hiera('profile::haproxy::services::ipv6', false)
  $certificate = hiera('profile::haproxy::services::apicert::certfile', false)
  $certfile = hiera('profile::haproxy::services::apicert::certfile',
                    '/etc/ssl/private/haproxy.servicesapi.pem')

  $ft_options = {
    'default_backend' => 'bk_keystone_public',
  }

  if($certificate) {
    $ssl = ['ssl', 'crt', $certfile]
  } else {
    $ssl = []
  }

  if($ipv6) {
    $bind = {
      "${ipv4}:5000" => $ssl,
      "${ipv6}:5000" => $ssl,
    }
  } else {
    $bind = {
      "${ipv4}:5000" => $ssl,
    }
  }

  haproxy::frontend { 'ft_keystone_public':
    bind    => $bind,
    mode    => 'http',
    options => $ft_options,
  }

  haproxy::backend { 'bk_keystone_public':
    mode    => 'http',
    options => {
      'balance' => 'source',
      'option'  => [
        'tcplog',
        'tcpka',
        'httpchk',
      ],
    },
  }
}
