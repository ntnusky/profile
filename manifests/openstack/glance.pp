# Installs and configures the glance service on an openstack controller node in
# the SkyHiGh architecture
class profile::openstack::glance {
  contain ::profile::openstack::glance::api
  contain ::profile::openstack::glance::registry
}
