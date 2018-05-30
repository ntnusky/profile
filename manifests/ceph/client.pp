# This class installs the ceph client, and configures to be able to use the ceph
# cluster.
class profile::ceph::client {
  $admin_key = hiera('profile::ceph::admin_key')

  require ::profile::ceph::base
  include ::profile::ceph::key::admin

  ceph_config {
    'client/rbd cache':
      value => true;
    'client/rbd cache writethrough until flush':
      value => true;
  }
}
