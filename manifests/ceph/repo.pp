# Abstraction for the ceph::repo class
class profile::ceph::repo {
  if($::facts['os']['distro']['codename'] == 'jammy') {
    $default = false
  } else {
    $default = true
  }

  $setup_repo = lookup('profile::ceph::repo::enabled', {
    'default_value' = $default,
    'value_type'    = Boolean,
  })

  if ( $setup_repo ) {
    class { '::ceph::repo':
      enable_epel => false,
      enable_sig  => true,
    }
  }
}
