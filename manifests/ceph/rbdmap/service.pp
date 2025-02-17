# Define the rbdmap service so other classes can restart it.
class profile::ceph::rbdmap::service {
  service { 'rbdmap':
  }
}
