# If the host is a CentOS machine, enable the powertools repo
class profile::repo::powertools {
  if $facts['os']['family'] {
    if $facts['os']['release']['major'] == '8' {
      yumrepo { 'PowerTools':
        enabled => '1',
      }
    }
  }
}
