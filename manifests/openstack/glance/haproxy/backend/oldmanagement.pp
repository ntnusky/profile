# This class configures haproxy-backends for glance based on a hiera-key. Can
# be used to include glance-servers not administerd by the same
# puppet-infrastructure in the rotation.
class profile::openstack::glance::haproxy::backend::oldmanagement {
  $controllers = hiera_hash('profile::openstack::oldcontrollers', false)

  if($controllers) {
    $names = keys($controllers)
    $addresses = values($controllers)

    haproxy::balancermember { 'glance-admin-static':
      listening_service => 'bk_glance_api_admin',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '9292',
      options           => 'check inter 2000 rise 2 fall 5',
    }

    haproxy::balancermember { 'glance-registry-static':
      listening_service => 'bk_glance_registry',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '9191',
      options           => 'check inter 2000 rise 2 fall 5',
    }
  }
}
