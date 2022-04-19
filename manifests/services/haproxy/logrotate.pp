# Configures hourly rotation of haproxy logs.
class profile::services::haproxy::logrotate {
  logrotate::rule { 'haproxylogs':
    path         => ['/var/log/haproxy.log'],
    rotate       => 504,
    rotate_every => 'hour',
  }
}
