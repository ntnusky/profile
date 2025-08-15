# This class configures the UEFI boot-order to first do a network-boot, then
# start the OS. 
class profile::baseconfig::uefi {
  $enable = lookup('profile::baseconfig::uefi::bootorder', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  if ( $enable and '/boot/efi' in $::facts['mountpoints']) {
    $files = [ 'uefi-bootorder-set.sh', 'uefi-bootorder-verify.sh' ]
    $files.each | $filename | {
      file { "/usr/local/sbin/${filename}":
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0700',
        source => "puppet:///modules/profile/uefi/${filename}",
        before => Exec['Set boot-order to NIC before OS'],
      }
    }

    exec { 'Set boot-order to NIC before OS':
      command => '/usr/local/sbin/uefi-bootorder-set.sh',
      unless  => '/usr/local/sbin/uefi-bootorder-verify.sh',
    }
  }
}
