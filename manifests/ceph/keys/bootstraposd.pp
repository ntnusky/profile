# Install and configure ceph-mon
class profile::ceph::keys::bootstraposd {
  $bootstrap_osd_key = hiera('profile::ceph::osd_bootstrap_key')

  ceph::key { 'client.bootstrap-osd':
    secret         => $bootstrap_osd_key,
    cap_mon        => 'allow profile bootstrap-osd',
    inject         => true,
    inject_as_id   => 'mon.',
    inject_keyring => "/var/lib/ceph/mon/ceph-${::hostname}/keyring",
  }
}
