# Dependencies
class profile::monitoring::munin::deps {
  if $facts['os']['family'] {
    if $facts['os']['release']['major'] == '8' {
      yumrepo { 'PowerTools':
        enabled => '1',
      }
    }
  }
}
