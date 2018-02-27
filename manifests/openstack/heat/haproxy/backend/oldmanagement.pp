# This class configures haproxy-backends for heat based on a hiera-key. Can
# be used to include heat-servers not administerd by the same
# puppet-infrastructure in the rotation.
class profile::openstack::heat::haproxy::backend::oldmanagement {
  $controllers = hiera_hash('profile::openstack::oldcontrollers', false)

  if($controllers) {
    $names = keys($controllers)
    $addresses = values($controllers)

    haproxy::balancermember { 'heat-admin-static':
      listening_service => 'bk_heat_api_admin',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '8004',
      options           => 'check inter 2000 rise 2 fall 5',
    }

    haproxy::balancermember { 'heat-cfn-admin-static':
      listening_service => 'bk_heat_cfn_admin',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '8000',
      options           => 'check inter 2000 rise 2 fall 5',
    }
  }
}
