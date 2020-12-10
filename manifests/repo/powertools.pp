# If the host is a CentOS machine, enable the powertools repo
class profile::repo::powertools {

  # To clean up the mess CentOS 8.3 created
  # Can be removed when all hosts are cleaned
  file { '/etc/yum.repos.d/PowerTools.repo':
    ensure => 'absent',
  }

  if $facts['os']['family'] {
    if $facts['os']['release']['major'] == '8' {
      yumrepo { 'powertools':
        enabled => '1',
      }
    }
  }
}
