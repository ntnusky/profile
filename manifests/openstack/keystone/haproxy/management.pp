# Configures the haproxy frontend for the internal and admin keystone API
class profile::openstack::keystone::haproxy::management {
  require ::profile::services::haproxy
  include ::profile::openstack::keystone::firewall::haproxy::management

  $ipv4 = hiera('profile::haproxy::management::ipv4')
  $ipv6 = hiera('profile::haproxy::management::ipv6', false)

  $ft_admin_options = {
    'default_backend' => 'bk_keystone_admin',
  }
  $ft_internal_options = {
    'default_backend' => 'bk_keystone_internal',
  }

  if($ipv6) {
    haproxy::frontend { 'ft_keystone_admin':
      bind    => {
        "${ipv4}:35357" => [],
        "${ipv6}:35357" => [],
      },
      mode    => 'tcp',
      options => $ft_admin_options,
    }
    haproxy::frontend { 'ft_keystone_internal':
      bind    => {
        "${ipv4}:5000" => [],
        "${ipv6}:5000" => [],
      },
      mode    => 'tcp',
      options => $ft_internal_options,
    }
  } else {
    haproxy::frontend { 'ft_keystone_admin':
      ipaddress => $ipv4,
      ports     => '35357',
      mode      => 'tcp',
      options   => $ft_admin_options,
    }
    haproxy::frontend { 'ft_keystone_internal':
      ipaddress => $ipv4,
      ports     => '5000',
      mode      => 'tcp',
      options   => $ft_internal_options,
    }
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
    mode    => 'tcp',
    options => $backend_options,
  }

  haproxy::backend { 'bk_keystone_internal':
    mode    => 'tcp',
    options => $backend_options,
  }
}
