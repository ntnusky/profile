# This class sets up the openstack repositories.
class profile::openstack::repo(
){
  if $::osfamily == 'Debian' {
    if $::operatingsystem == 'Ubuntu' {
      class { '::openstack_extras::repo::debian::ubuntu':
        package_require => true,
        }
      }
    } elsif $::operatingsystem == 'Debian' {
      class { '::openstack_extras::repo::debian::debian':
        package_require => true,
      }
    } else {
      fail("Operating system ${::operatingsystem} is not supported.")
    }
  } elsif $::osfamily == 'RedHat' {
      class { '::openstack_extras::repo::redhat::redhat':
      }
  } else {
      fail("Operating system family ${::osfamily} is not supported.")
  }
}
