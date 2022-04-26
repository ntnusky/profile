# Configures hourly rotation of haproxy logs.
class profile::services::haproxy::logrotate {
  $default_su = $facts['os']['name'] ? {
    'Ubuntu' => true,
    default  => false,
  }
  $default_su_user = $facts['os']['name'] ? {
    'Ubuntu' => 'root',
    default  => undef,
  }
  $default_su_group = $facts['os']['name'] ? {
    'Ubuntu' => 'syslog',
    default  => undef,
  }

  logrotate::rule { 'haproxylogs':
    path          => ['/var/log/haproxy.log'],
    compress      => true,
    delaycompress => true,
    ifempty       => false,
    missingok     => true,
    postrotate    => '/usr/lib/rsyslog/rsyslog-rotate',
    rotate        => 504,
    rotate_every  => 'hour',
    su            => $default_su,
    su_user       => $default_su_user,
    su_group      => $default_su_group,
  }
}
