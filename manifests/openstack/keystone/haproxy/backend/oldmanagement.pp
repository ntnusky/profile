# This class configures haproxy-backends for keystone based on a hiera-key. Can
# be used to include keystone-servers not administerd by the same
# puppet-infrastructure in the rotation.
class profile::openstack::keystone::haproxy::backend::oldmanagement {
  $controllers = hiera_hash('profile::openstack::oldcontrollers', false)

  if($controllers) {
    $names = keys($controllers)
    $addresses = values($controllers)

    haproxy::balancermember { 'keystone-admin-static':
      listening_service => 'bk_keystone_admin',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '35357',
      options           => 'check inter 2000 rise 2 fall 5',
    }

    haproxy::balancermember { 'keystone-internal-static':
      listening_service => 'bk_keystone_internal',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '5000',
      options           => 'check inter 2000 rise 2 fall 5',
    }
  }
}
