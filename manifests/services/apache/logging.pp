# This class configures log-inputs from apache
class profile::services::apache::logging {
  profile::utilities::logging::module { 'apache' :
    content => [{
      'module' => 'apache',
      'access' => {
        'enabled' => true,
        'var.paths' => [
          '/var/log/apache2/*access.log*',
          '/var/log/httpd/*access.log*',
          '/var/log/httpd/*access_log*',
        ],
      },
      'error' => {
        'enabled' => true,
        'var.paths' => [
          '/var/log/apache2/*error.log*',
          '/var/log/httpd/*error.log*',
          '/var/log/httpd/*error_log*',
        ],
      },
    }]
  }
}
