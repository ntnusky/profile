# Configure filebeat module for haproxy
class profile::services::haproxy::logging {
  profile::utilities::logging::module { 'haproxy' :
    content => [{
      'module' => 'haproxy',
      'log'    => {
        'enabled'   => true,
        'var.input' => 'file',
        'var.paths' => [
          '/var/log/haproxy.log',
        ],
      },
    }]
  }
}
