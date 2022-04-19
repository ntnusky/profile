# Configures hourly rotation of haproxy logs.
class profile::services::haproxy::logrotate {
  logrotate::rule { 'haproxylogs':
    path          => ['/var/log/haproxy.log'],
    compress      => true,
    delaycompress => true,
    ifempty       => false,
    missingok     => true,
    postrotate    => '/usr/lib/rsyslog/rsyslog-rotate',
    rotate        => 504,
    rotate_every  => 'hour',
  }
}
