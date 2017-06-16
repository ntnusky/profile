# Installs and configures the cinder service on an openstack controller node in
# the SkyHiGh architecture
class profile::openstack::cinder {
  contain ::profile::openstack::cinder::api
  contain ::profile::openstack::cinder::scheduler
  contain ::profile::openstack::cinder::volume
}
