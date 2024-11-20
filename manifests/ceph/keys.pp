# Configures ceph-keys based on lists in hiera
class profile::ceph::keys {
  $keydata = lookup('profile::ceph::keys', {
    'default_value' => {},
    'value_type'    => Hash[String, Hash],
  })

  $keydata.each | $keyname, $data | {
    ::profile::ceph::key { $keyname :
      inject => pick($data['inject'], true),
    }
  }
}
