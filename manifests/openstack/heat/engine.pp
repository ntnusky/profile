# Installs and configures the heat engine.
class profile::openstack::heat::engine {
  # Determine which endpoint to use
  $heat_admin_ip = hiera('profile::api::heat::admin::ip')
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', undef)
  $heat_internal  = pick($internal_endpoint, "http://${heat_admin_ip}")

  # Retrieve other settings:
  $auth_encryption_key = hiera('profile::heat::auth_encryption_key')

  require ::profile::openstack::repo
  require ::profile::openstack::heat::base

  class { '::heat::engine':
    auth_encryption_key           => $auth_encryption_key,
    heat_metadata_server_url      => "${heat_internal}:8000",
    heat_waitcondition_server_url => "${heat_internal}:8000/v1/waitcondition",
  }
}
