# Class to set defaults for logrotate
class profile::baseconfig::logrotate {

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

  logrotate::conf { '/etc/logrotate.conf':
    compress => true,
    su       => $default_su,
    su_user  => $default_su_user,
    su_group => $default_su_group,
  }
}
