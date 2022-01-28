# Configures all needed bits to graph the traffic/iops to/from a single ceph
# pool.
define profile::ceph::monitoring::pool {
  include ::profile::ceph::monitoring::collectors
  include ::profile::monitoring::munin::plugin::ceph::base
  include ::profile::systemd::reload

  # Remove the cephcollector service-file
  file { "/lib/systemd/system/cephcollector.${name}.service":
    ensure  => absent,
    notify  => Exec['systemd-reload'],
  }
}
