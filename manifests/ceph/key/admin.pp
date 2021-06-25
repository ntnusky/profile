# Installs the client.admin ceph key
class profile::ceph::key::admin {
  $admin_key = lookup('profile::ceph::admin_key')

  ceph::key { 'client.admin':
    secret  => $admin_key,
    cap_mon => 'allow *',
    cap_osd => 'allow *',
    cap_mds => 'allow',
    cap_mgr => 'allow *',
  }
}
