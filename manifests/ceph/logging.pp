# This class configures log-inputs from ceph
class profile::ceph::logging {
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  # Only set up remote-logging if there are defined any log-servers in hiera. 
  if $loggservers{
    # Input ceph-logs, and treat lines not starting with a digit as part of the
    # previous line.
    filebeat::input { 'ceph':
      paths     => [
        '/var/log/ceph/*.log',
      ],
      doc_type  => 'log',
      multiline => {
        'pattern' => '^[^0-9]',
        'negate'  => 'true',
        'match'   => 'after',
      },
      tags      => [ 'ceph' ],
    }
  }
}
