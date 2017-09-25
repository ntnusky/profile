# Installs pgpool for HA postgres
class profile::services::postgresql::pgpool {
  $management_if = hiera('profile::interfaces::management')
  $management_ip = hiera("profile::interfaces::${management_if}::address")

  $servers = hiera_array('profile::postgres::servers')

  package { 'pgpool2':
    ensure => present,
  }

  ini_setting { 'pgpool listen_address':
    ensure  => present,
    path    => '/etc/pgpool2/pgpool.conf',
    section => '',
    setting => 'listen_addresses',
    value   => $management_ip,
  }

  $servers.each |$server| {
    $id = hiera("profile::postgres::${server}::id")
    $port = hiera("profile::postgres::${server}::port", '5433')
    $datadir = hiera("profile::postgres::${server}::id",
        '/var/lib/postgresql/9.5/main/')
    $weight = hiera("profile::postgres::${server}::id", 1)
    $flag = hiera("profile::postgres::${server}::flag", 'ALLOW_TO_FAILOVER')

    ini_setting { 'pgpool ${id} hostname':
      ensure  => present,
      path    => '/etc/pgpool2/pgpool.conf',
      section => '',
      setting => 'backend_hostname${id}',
      value   => $server,
    }

    ini_setting { 'pgpool ${id} port':
      ensure  => present,
      path    => '/etc/pgpool2/pgpool.conf',
      section => '',
      setting => 'backend_port${id}',
      value   => $port,
    }

    ini_setting { 'pgpool ${id} weight':
      ensure  => present,
      path    => '/etc/pgpool2/pgpool.conf',
      section => '',
      setting => 'backend_weight${id}',
      value   => $weight,
    }

    ini_setting { 'pgpool ${id} datadir':
      ensure  => present,
      path    => '/etc/pgpool2/pgpool.conf',
      section => '',
      setting => 'backend_data_directory${id}',
      value   => $datadir,
    }

    ini_setting { 'pgpool ${id} flag':
      ensure  => present,
      path    => '/etc/pgpool2/pgpool.conf',
      section => '',
      setting => 'backend_flag${id}',
      value   => $flag,
    }
  }
}
