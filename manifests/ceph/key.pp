# Configures ceph-key based on the list in hiera
define profile::ceph::key (
  Boolean $inject = false,
) {
  $keydata = lookup('profile::ceph::keys', {
    'default_value' => {},
    'value_type'    => Hash[String, Hash],
  })

  if($data[$name]['caps_mds']) {
    $cap_mds = $data[$name]['caps_mds'].join(', ')
  } else {
    $cap_mds = undef
  }

  if($data[$name]['caps_mgr']) {
    $cap_mgr = $data[$name]['caps_mgr'].join(', ')
  } else {
    $cap_mgr = undef
  }

  if($data[$name]['caps_mon']) {
    $cap_mon = $data[$name]['caps_mon'].join(', ')
  } else {
    $cap_mon = undef
  }

  if($data[$name]['caps_osd']) {
    $cap_osd = $data[$name]['caps_osd'].join(', ')
  } else {
    $cap_osd = undef
  }

  ceph::key { $keyname:
    cap_mds => $cap_mds,
    cap_mgr => $cap_mgr,
    cap_mon => $cap_mon,
    cap_osd => $cap_osd,
    inject  => $inject,
    secret  => $data[$name]['secret'],
  }
}
