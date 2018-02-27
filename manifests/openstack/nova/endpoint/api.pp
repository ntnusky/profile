# Registers the nova api endpoint in keystone
class profile::openstack::nova::endpoint::api {
  $nova_password = hiera('profile::nova::keystone::password')
  $region = hiera('profile::region')

  $nova_public_ip = hiera('profile::api::nova::public::ip')
  $nova_admin_ip = hiera('profile::api::nova::admin::ip')
  $keystone_public_ip = hiera('profile::api::keystone::public::ip')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip')

  $admin_endpoint = hiera('profile::openstack::endpoint::admin', false)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', false)
  $public_endpoint = hiera('profile::openstack::endpoint::public', false)

  $nova_admin    = pick($admin_endpoint, "http://${nova_admin_ip}")
  $nova_internal = pick($internal_endpoint, "http://${nova_admin_ip}")
  $nova_public   = pick($public_endpoint, "http://${nova_public_ip}")

  require ::profile::openstack::repo
  require ::profile::openstack::nova::base

  class { '::nova::keystone::auth':
    password        => $nova_password,
    public_url      => "${nova_public}:8774/v2/%(tenant_id)s",
    internal_url    => "${nova_internal}:8774/v2/%(tenant_id)s",
    admin_url       => "${nova_admin}:8774/v2/%(tenant_id)s",
    public_url_v3   => "${nova_public}:8774/v3",
    internal_url_v3 => "${nova_internal}:8774/v3",
    admin_url_v3    => "${nova_admin}:8774/v3",
    region          => $region,
  }
}
