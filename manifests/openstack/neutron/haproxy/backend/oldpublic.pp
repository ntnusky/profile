# This class configures haproxy-backends for neutron based on a hiera-key. Can
# be used to include neutron-servers not administerd by the same
# puppet-infrastructure in the rotation.
class profile::openstack::neutron::haproxy::backend::oldpublic {
  $controllers = hiera_hash('profile::openstack::oldcontrollers', false)

  if($controllers) {
    $names = keys($controllers)
    $addresses = values($controllers)

    haproxy::balancermember { 'neutron-public-static':
      listening_service => 'bk_neutron_public',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '9696',
      options           => 'check inter 2000 rise 2 fall 5',
    }
  }
}
