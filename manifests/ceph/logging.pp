# This class configures log-inputs from ceph
class profile::ceph::logging {
  # Input ceph-logs, and treat lines not starting with a digit as part of the
  # previous line.
  profile::utilities::logging::file { 'ceph':
    paths     => [
      '/var/log/ceph/*.log',
    ],
    multiline => {
      'pattern' => '^[0-9]{4}-[0-9]{2}-[0-9]{2}',
      'negate'  => 'true',
      'match'   => 'after',
    },
    tags      => [ 'ceph' ],
  }
}
