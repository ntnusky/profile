# Configures the puppetmaster to send reports to the SL dashboard
class profile::services::puppet::server::config::report {
  $dash_url = lookup('shiftleader::params::puppetapi_name', Optional[String])
  if($dash_url) {
    $report_url = "https://${dash_url}/puppet/report"
    puppet::config::server {
      'reports':   value => 'http';
      'reporturl': value => $report_url;
    }
  }
}
