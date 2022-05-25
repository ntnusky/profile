# This class configures log-inputs from libvirt
class profile::services::libvirt::logging {
  profile::utilities::logging::file { 'libvirt':
    paths     => [
      '/var/log/libvirt/qemu/*.log',
    ],
    multiline => {
      'type'    => 'pattern',
      'pattern' => '^[0-9]',
      'negate'  => 'true',
      'match'   => 'after',
    },
    tags      => [ 'libvirt' ],
  }
}
