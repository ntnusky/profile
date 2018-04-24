# Configures the keystone endpoint for the cinder API
class profile::openstack::cinder::endpoint {
  # Openstack settings
  $region = hiera('profile::region')
  $keystone_password = hiera('profile::cinder::keystone::password')

  # Determine the endpoint addresses
  $cinder_public_ip = hiera('profile::api::cinder::public::ip')
  $cinder_admin_ip = hiera('profile::api::cinder::admin::ip')
  $admin_endpoint = hiera('profile::openstack::endpoint::admin', undef)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', undef)
  $public_endpoint = hiera('profile::openstack::endpoint::public', undef)
  $cinder_admin    = pick($admin_endpoint, "http://${cinder_admin_ip}")
  $cinder_internal = pick($internal_endpoint, "http://${cinder_admin_ip}")
  $cinder_public   = pick($public_endpoint, "http://${cinder_public_ip}")

  require ::profile::openstack::repo

  class  { '::cinder::keystone::auth':
    password        => $keystone_password,
    public_url      => "${cinder_public}:8776/v1/%(tenant_id)s",
    internal_url    => "${cinder_internal}:8776/v1/%(tenant_id)s",
    admin_url       => "${cinder_admin}:8776/v1/%(tenant_id)s",
    public_url_v2   => "${cinder_public}:8776/v2/%(tenant_id)s",
    internal_url_v2 => "${cinder_internal}:8776/v2/%(tenant_id)s",
    admin_url_v2    => "${cinder_admin}:8776/v2/%(tenant_id)s",
    public_url_v3   => "${cinder_public}:8776/v3/%(tenant_id)s",
    internal_url_v3 => "${cinder_internal}:8776/v3/%(tenant_id)s",
    admin_url_v3    => "${cinder_admin}:8776/v3/%(tenant_id)s",
    region          => $region,
  }
}
