# Installs and configures the glance service on an openstack controller node in
# the SkyHiGh architecture
class profile::openstack::glance {
  include ::profile::openstack::glance::api
  include ::profile::openstack::glance::database
  include ::profile::openstack::glance::keepalived
  include ::profile::openstack::glance::service
  include ::profile::openstack::glance::sudo
}
