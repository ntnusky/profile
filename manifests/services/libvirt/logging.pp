# This class configures log-inputs from libvirt
class profile::services::libvirt::logging {
  $loggservers = lookup('profile::logstash::servers', {
    'value_type'    => Variant[Boolean, Array[String]],
    'default_value' => false,
  })

  # Only set up remote-logging if there are defined any log-servers in hiera. 
  if $loggservers{
    # Input libvirt-logs, and treat lines not starting with a digit as part of
    # the previous line.
    filebeat::input { 'libvirt':
      paths     => [
        '/var/log/libvirt/qemu/*.log',
      ],
      doc_type  => 'log',
      multiline => {
        'type'    => 'pattern',
        'pattern' => '^[0-9]',
        'negate'  => 'true',
        'match'   => 'after',
      },
      tags      => [ 'libvirt' ],
    }
  }
}
