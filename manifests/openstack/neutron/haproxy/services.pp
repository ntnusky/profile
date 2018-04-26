# Configures the haproxy frontend for the public neutron API
class profile::openstack::neutron::haproxy::services {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::serviceapi

  include ::profile::openstack::neutron::firewall::haproxy
  include ::profile::openstack::neutron::haproxy::backend::oldpublic

  $ipv4 = hiera('profile::haproxy::services::ipv4')
  $ipv6 = hiera('profile::haproxy::services::ipv6', false)
  $certificate = hiera('profile::haproxy::services::apicert', false)
  $certfile = hiera('profile::haproxy::services::apicert::certfile',
                    '/etc/ssl/private/haproxy.servicesapi.pem')

  if($certificate) {
    $ssl = ['ssl', 'crt', $certfile]
    $proto = 'X-Forwarded-Proto:\ https'
  } else {
    $ssl = []
    $proto = 'X-Forwarded-Proto:\ http'
  }

  $ft_options = {
    'default_backend' => 'bk_neutron_public',
    'reqadd'          => $proto,
  }

  if($ipv6) {
    $bind = {
      "${ipv4}:9696" => $ssl,
      "${ipv6}:9696" => $ssl,
    }
  } else {
    $bind = {
      "${ipv4}:9696" => $ssl,
    }
  }

  haproxy::frontend { 'ft_neutron_public':
    bind    => $bind,
    mode    => 'http',
    options => $ft_options,
  }

  haproxy::backend { 'bk_neutron_public':
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
