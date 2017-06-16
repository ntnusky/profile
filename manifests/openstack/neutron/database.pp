# Sets up the neutron database
class profile::openstack::neutron::database {
  $password = hiera('profile::mysql::neutronpass')
  $allowed_hosts = hiera('profile::mysql::allowed_hosts')

  class { '::neutron::db::mysql' :
    password      => $password,
    allowed_hosts => $allowed_hosts,
  }
}
