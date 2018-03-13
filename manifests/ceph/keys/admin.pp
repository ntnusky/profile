# Injects the ceph admin key
class profile::ceph::keys::admin {
  $admin_key = hiera('profile::ceph::admin_key')

  ceph::key { 'client.admin':
    secret         => $admin_key,
    cap_mon        => 'allow *',
    cap_osd        => 'allow *',
    cap_mds        => 'allow',
    cap_mgr        => 'allow *',
    inject         => true,
    inject_as_id   => 'mon.',
    inject_keyring => "/var/lib/ceph/mon/ceph-${::hostname}/keyring",
  }
}
