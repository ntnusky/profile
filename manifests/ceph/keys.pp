# Configures ceph-keys based on lists in hiera
class profile::ceph::keys {
  $keydata = lookup('profile::ceph::keys', {
    'default_value' => {},
    'value_type'    => Hash[String, Hash],
  })

  $keydata.each | $keyname, $data | {
    if($data['cap_mds']) {
      $cap_mds = $data['cap_mds'].join(',')
    } else {
      $cap_mds = undef
    }

    if($data['cap_mgr']) {
      $cap_mgr = $data['cap_mgr'].join(',')
    } else {
      $cap_mgr = undef
    }

    if($data['cap_mon']) {
      $cap_mon = $data['cap_mon'].join(',')
    } else {
      $cap_mon = undef
    }

    if($data['cap_osd']) {
      $cap_osd = $data['cap_osd'].join(',')
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
