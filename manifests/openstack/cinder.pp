# Installs and configures the cinder service on an openstack controller node in
# the SkyHiGh architecture
class profile::openstack::cinder {
  include ::profile::openstack::cinder::api
  include ::profile::openstack::cinder::ceph
  include ::profile::openstack::cinder::database
  include ::profile::openstack::cinder::keepalived
  include ::profile::openstack::cinder::service
  include ::profile::openstack::cinder::sudo
}
