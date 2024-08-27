# Installs the mgr ceph key
class profile::ceph::key::mgr {
  $mgr_key = lookup('profile::ceph::mgr_key', String)

  ceph::key { "mgr.${::hostname}":
    secret  => $mgr_key,
    cap_mon => 'allow *',
    cap_osd => 'allow *',
    cap_mds => 'allow *',
    cluster => 'ceph',
    group   => 'ceph',
    user    => 'ceph',
  }
}
