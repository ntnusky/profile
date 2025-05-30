# Abstraction for the ceph::repo class
class profile::ceph::repo {
  $release = lookup('ceph::params::release')
  if($::facts['os']['distro']['codename'] == 'jammy' and $release == 'quincy') {
    $default = 'absent'
  } else {
    $default = 'present'
  }

  $ensure = lookup('profile::ceph::repo::ensure', {
    'default_value' => $default,
    'value_type'    => String,
  })

  class { '::ceph::repo':
    ensure      => $ensure,
    enable_epel => false,
    enable_sig  => true,
  }
}
