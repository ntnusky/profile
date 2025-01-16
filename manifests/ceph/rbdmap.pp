# Define a new rbdmap
define profile::ceph::rbdmap (
  String $image,
  String $user,
  String $keyring,
) {
  include ::profile::ceph::rbdmap::service

  file_line { "RBDMAP-${name}":
    line   => "${image} id=${user},keyring=${keyring}",
    path   => '/etc/ceph/rbdmap',
    notify => Service['rbdmap'],
  }
}
