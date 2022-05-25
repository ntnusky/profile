# This class configures log-inputs from ovs
class profile::infrastructure::ovs::logging {
  # Input ceph-logs, and treat lines not starting with a digit as part of the
  # previous line.
  profile::utilities::logging::file { 'ovs':
    paths    => [
      '/var/log/openvswitch/ovs-vswitchd.log',
      '/var/log/openvswitch/ovsdb-server.log',
    ],
    tags     => [ 'vswitch' ],
  }
}
