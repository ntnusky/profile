# This class configures haproxy-backends for cinder based on a hiera-key. Can
# be used to include cinder-servers not administerd by the same
# puppet-infrastructure in the rotation.
class profile::openstack::cinder::haproxy::backend::oldmanagement {
  $controllers = hiera_hash('profile::openstack::oldcontrollers', false)

  if($controllers) {
    $names = keys($controllers)
    $addresses = values($controllers)

    haproxy::balancermember { 'cinder-admin-static':
      listening_service => 'bk_cinder_api_admin',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '8776',
      options           => 'check inter 2000 rise 2 fall 5',
    }
  }
}
