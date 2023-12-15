# Configures the puppetmaster to send reports to the SL dashboard
class profile::services::puppet::server::config::report {
  if($sl_version == 1) {
    $dash_url = lookup('profile::dashboard::name::v4only', Stdlib::Fqdn)
    $report_url = "http://${dash_url}/web/puppet/report/"
  } else {
    $dash_url = lookup('shiftleader::params::puppetapi_name', Optional[String])
    if($dash_url) {
      $report_url = "https://${dash_url}/puppet/report"
    } else {
      $report_url = undef 
    }
  }

  if ($report_url) {
    $ensure = 'present'
  } else {
    $ensure = 'absent'
  }

  ini_setting { 'Puppetmaster report':
    ensure  => $ensure,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'reports',
    value   => 'http',
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }

  ini_setting { 'Puppetmaster report url':
    ensure  => $ensure,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'master',
    setting => 'reporturl',
    value   => $report_url,
    notify  => Service['puppetserver'],
    require => Package['puppetserver'],
  }
}
