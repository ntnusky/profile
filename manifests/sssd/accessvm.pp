# Overrides for sssd-config in access-vm

class profile::sssd::accessvm {

  file {'/usr/local/bin/keystone-logon':
    ensure  => file,
    owner   => 'root',
    mode    => '0755',
    content => template('profile/keystone-logon.erb'),
  }

  class { 'profile::sssd::ldap':
    shell => '/usr/local/bin/keystone-logon',
  }
}
