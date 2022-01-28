# Adds an exec which can be notified to reload systemd configuration
class profile::systemd::reload {
  exec { 'systemd-reload':
    command     => '/bin/systemctl daemon-reload',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    refreshonly => true,
  }
}
