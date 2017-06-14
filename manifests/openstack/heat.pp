# Installs and configures the heat service on an openstack controller node in
# the SkyHiGh architecture
class profile::openstack::heat {
  contain ::profile::openstack::heat::api
  contain ::profile::openstack::heat::engine
}
