# Installs and configures the heat engine.
class profile::openstack::heat::engine {
  $heat_public_ip = hiera('profile::api::heat::public::ip')
  $auth_encryption_key = hiera('profile::heat::auth_encryption_key')

  require ::profile::openstack::repo
  require ::profile::openstack::heat::base

  class { 'heat::engine':
    auth_encryption_key           => $auth_encryption_key,
    heat_metadata_server_url      => "http://${heat_public_ip}:8000",
    heat_waitcondition_server_url =>
      "http://${heat_public_ip}:8000/v1/waitcondition",
  }
}
