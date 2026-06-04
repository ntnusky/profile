# Sane defaults for ignored services in needrestart
class profile::baseconfig::needrestart {
  $overrides = lookup('profile::baseconfig::needrestart::overrides', {
    'default_value' => {
      'override_rc' => {
        'qr(^ceph)'         => 0,
        'qr(^openvswitch)'  => 0,
        'qr(^ovs-vswitchd)' => 0,
        'qr(^ovsdb-server)' => 0
      },
    },
    'value_type' => Hash,
    })

  class { '::needrestart':
    configs => $overrides,
  }
}
