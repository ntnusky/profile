# Configures ceph-keys based on lists in hiera
class profile::ceph::keys {
  $keydata = lookup('profile::ceph::keys', {
    'default_value' => {},
    'value_type'    => Hash[String, Hash],
  })

  $keydata.each | $keyname, $data | {
    if($data['caps_mds']) {
      $cap_mds = $data['caps_mds'].join(', ')
    } else {
      $cap_mds = undef
    }

    if($data['caps_mgr']) {
      $cap_mgr = $data['caps_mgr'].join(', ')
    } else {
      $cap_mgr = undef
    }

    if($data['caps_mon']) {
      $cap_mon = $data['caps_mon'].join(', ')
    } else {
      $cap_mon = undef
    }

    if($data['caps_osd']) {
      $cap_osd = $data['caps_osd'].join(', ')
    } else {
      $cap_osd = undef
    }

    ceph::key { $keyname:
      cap_mds => $cap_mds,
      cap_mgr => $cap_mgr,
      cap_mon => $cap_mon,
      cap_osd => $cap_osd,
      inject  => pick($data['inject'], true),
      secret  => $data['secret'],
    }
  }
}
