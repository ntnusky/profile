# Installs and configures the keystone service on an openstack controller node
# in the SkyHiGh architecture
class profile::openstack::keystone {
  contain ::profile::openstack::keystone::api
  contain ::profile::openstack::keystone::ldap
}
