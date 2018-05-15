# Installs and configures the nova APIs.
class profile::openstack::nova::api {
  contain ::profile::openstack::nova::api::compute
  contain ::profile::openstack::nova::api::placement
}
