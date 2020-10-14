# This class configures log-inputs from ovs
class profile::infrastructure::ovs::logging {
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  # Only set up remote-logging if there are defined any log-servers in hiera. 
  if $loggservers{
    # Input ceph-logs, and treat lines not starting with a digit as part of the
    # previous line.
    filebeat::input { 'ovs':
      paths    => [
        '/var/log/openvswitch/ovs-vswitchd.log',
        '/var/log/openvswitch/ovsdb-server.log',
      ],
      doc_type => 'log',
      tags     => [ 'vswitch' ],
    }
  }
}
