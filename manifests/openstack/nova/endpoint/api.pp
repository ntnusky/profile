# Registers the nova api endpoint in keystone
class profile::openstack::nova::endpoint::api {
  $nova_password = hiera('profile::nova::keystone::password')
  $region = hiera('profile::region')

  $nova_public_ip = hiera('profile::api::nova::public::ip', '127.0.0.1')
  $nova_admin_ip = hiera('profile::api::nova::admin::ip', '127.0.0.1')
  $keystone_public_ip = hiera('profile::api::keystone::public::ip', '127.0.0.1')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')

  $admin_endpoint = hiera('profile::openstack::endpoint::admin', undef)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', undef)
  $public_endpoint = hiera('profile::openstack::endpoint::public', undef)

  $nova_admin    = pick($admin_endpoint, "http://${nova_admin_ip}")
  $nova_internal = pick($internal_endpoint, "http://${nova_admin_ip}")
  $nova_public   = pick($public_endpoint, "http://${nova_public_ip}")

  require ::profile::openstack::repo

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
