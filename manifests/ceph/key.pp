# Configures ceph-key based on the list in hiera
define profile::ceph::key (
  Boolean $inject = false,
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
    inject  => $inject,
    secret  => $keydata[$name]['secret'],
  }
}
