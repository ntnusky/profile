# Configures ceph-key based on the list in hiera
define profile::ceph::key (
  String           $group  = 'root',
  Boolean          $inject = false,
  Stdlib::Filemode $mode   = '0600',
  String           $user   = 'root',
) {
  $keydata = lookup('profile::ceph::keys', {
    'default_value' => {},
    'value_type'    => Hash[String, Hash],
  })

  if($keydata[$name]['caps_mds']) {
    $cap_mds = $keydata[$name]['caps_mds'].join(', ')
  } else {
    $cap_mds = undef
  }

  if($keydata[$name]['caps_mgr']) {
    $cap_mgr = $keydata[$name]['caps_mgr'].join(', ')
  } else {
    $cap_mgr = undef
  }

  if($keydata[$name]['caps_mon']) {
    $cap_mon = $keydata[$name]['caps_mon'].join(', ')
  } else {
    $cap_mon = undef
  }

  if($keydata[$name]['caps_osd']) {
    $cap_osd = $keydata[$name]['caps_osd'].join(', ')
  } else {
    $cap_osd = undef
  }

  ceph::key { $name:
    cap_mds => $cap_mds,
    cap_mgr => $cap_mgr,
    cap_mon => $cap_mon,
    cap_osd => $cap_osd,
    group   => $group,
    inject  => $inject,
    mode    => $mode,
    user    => $user,
    secret  => $keydata[$name]['secret'],
  }
}
