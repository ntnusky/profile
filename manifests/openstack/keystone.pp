# Installs and configures the keystone service on an openstack controller node
# in the SkyHiGh architecture
class profile::openstack::keystone {
  include ::profile::openstack::keystone::api
  include ::profile::openstack::keystone::database
  include ::profile::openstack::keystone::keepalived
  include ::profile::openstack::keystone::ldap
  include ::profile::openstack::keystone::tokenflush
}
