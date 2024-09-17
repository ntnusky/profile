# Create zbx_monitor role with needed privileges
class profile::services::postgresql::users::zabbixagent {
  $password = lookup('profile::postgres::zbx_monitor_password', String)
  $pw_hash = postgresql::postgresql_password('zbx_monitor', $password)

  postgresql::server::role { 'zbx_monitor':
    password_hash => $pw_hash,
    inherit       => true,
  }

  postgresql::server::grant_role { 'zbx_monitor-pg_monitor':
    role  => 'zbx_monitor',
    group => 'pg_monitor',
  }

  postgresql::server::database_grant { 'zbx_monitor-puppetdb':
    ensure    => 'present',
    db        => 'puppetdb',
    role      => 'zbx_monitor',
    privilege => 'CONNECT',
  }

  postgresql::server::pg_hba_rule { 'Allow zbx_monitor':
    description => 'Allow connections locally for zbx_monitor',
    type        => 'host',
    database    => 'all',
    user        => 'zbx_monitor',
    address     => '127.0.0.1/32',
    auth_method => 'md5',
  }
}
