# Installs pgpool for HA postgres
class profile::services::postgresql::pgpool {
  $management_if = hiera('profile::interfaces::management')
  $management_ip = hiera("profile::interfaces::${management_if}::address")

  $servers = hiera_hash('profile::postgres::servers')

  package { 'pgpool2':
    ensure => present,
  }

  service { 'pgpool2':
    ensure  => 'running',
    enable  => true,
    require => Package['pgpool2'],
  }

  ini_setting { 'pgpool listen_address':
    ensure  => present,
    path    => '/etc/pgpool2/pgpool.conf',
    section => '',
    setting => 'listen_addresses',
    value   => "'${management_ip}'",
    notify  => Service['pgpool2'],
  }

  $servers.each |$id, $server| {
    $port = hiera("profile::postgres::${id}::port", '5433')
    $datadir = hiera("profile::postgres::${id}::id",
        '/var/lib/postgresql/9.5/main/')
    $weight = hiera("profile::postgres::${id}::id", 1)
    $flag = hiera("profile::postgres::${id}::flag", 'ALLOW_TO_FAILOVER')

    ini_setting { "pgpool ${id} hostname":
      ensure  => present,
      path    => '/etc/pgpool2/pgpool.conf',
      section => '',
      setting => "backend_hostname${id}",
      value   => "'${server}'",
      notify  => Service['pgpool2'],
    }

    ini_setting { "pgpool ${id} port":
      ensure  => present,
      path    => '/etc/pgpool2/pgpool.conf',
      section => '',
      setting => "backend_port${id}",
      value   => $port,
      notify  => Service['pgpool2'],
    }

    ini_setting { "pgpool ${id} weight":
      ensure  => present,
      path    => '/etc/pgpool2/pgpool.conf',
      section => '',
      setting => "backend_weight${id}",
      value   => $weight,
      notify  => Service['pgpool2'],
    }

    ini_setting { "pgpool ${id} datadir":
      ensure  => present,
      path    => '/etc/pgpool2/pgpool.conf',
      section => '',
      setting => "backend_data_directory${id}",
      value   => "'${datadir}'",
      notify  => Service['pgpool2'],
    }

    ini_setting { "pgpool ${id} flag":
      ensure  => present,
      path    => '/etc/pgpool2/pgpool.conf',
      section => '',
      setting => "backend_flag${id}",
      value   => "'${flag}'",
      notify  => Service['pgpool2'],
    }
  }
}
