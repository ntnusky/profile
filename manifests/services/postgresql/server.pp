# This class installs and configures the postgresql server
class profile::services::postgresql::server {
  $management_if = lookup('profile::interfaces::management', String)
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ip = lookup("profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $mip
    })
  $database_port = lookup('profile::postgres::backend::port', {
    'value_type'    => Stdlib::Port,
    'default_value' => 5432
    })
  $postgresql_ipv4 = lookup('profile::postgres::ipv4')
  $postgresql_ipv6 = lookup('profile::postgres::ipv6', {
    'value_type'    => Variant[Stdlib::IP::Address::V6, Array],
    'default_value' => []
    })
  $password = lookup('profile::postgres::password', String)
  $replicator_password = lookup('profile::postgres::replicatorpassword', String)
  $master_server = lookup('profile::postgres::masterserver', String)

  if($::fqdn == $master_server) {
    $confpassword = $password
    postgresql::server::role { 'replicator':
      password_hash => postgresql_password('replicator', $replicator_password),
      replication   => true,
    }
  } else {
    $confpassword = undef
    postgresql::server::config_entry { 'hot_standby':
      value => 'on',
    }
  }

  class { '::postgresql::globals':
    manage_package_repo => true,
    version             => '9.6',
  }

  $ips = concat([$postgresql_ipv4], $postgresql_ipv6, '127.0.0.1', '::1',
      $management_ip)

  class { '::postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => join($ips, ','),
    port                       => scanf($database_port, '%i')[0],
    postgres_password          => $confpassword,
    manage_pg_ident_conf       => false,
  }

  class { '::postgresql::server::contrib': }


  postgresql::server::config_entry { 'wal_level':
    value => 'hot_standby',
  }

  postgresql::server::config_entry { 'max_wal_senders':
    value => '3',
  }

  postgresql::server::config_entry { 'checkpoint_segments':
    ensure => 'absent',
  }

  postgresql::server::config_entry { 'max_connections':
    value => '250',
  }

  postgresql::server::config_entry { 'wal_keep_segments':
    value => '8',
  }

  @@postgresql::server::pg_hba_rule { "allow ${management_ip} for replication":
    description => "Open up PostgreSQL for access from ${management_ip}",
    type        => 'host',
    database    => 'replication',
    user        => 'replicator',
    address     => "${management_ip}/32",
    auth_method => 'md5',
  }

  Postgresql::Server::Pg_hba_rule <<| |>>

  concat { '/var/lib/postgresql/.pgpass':
    ensure         => present,
    owner          => 'postgres',
    group          => 'postgres',
    mode           => '0600',
    warn           => true,
    ensure_newline => true,
  }
  concat { '/root/.pgpass':
    ensure         => present,
    owner          => 'root',
    group          => 'root',
    mode           => '0600',
    warn           => true,
    ensure_newline => true,
  }

  $mid = "${database_port}:replication:replicator"
  @@concat::fragment { "postgres replication ${management_ip}":
    target  => '/var/lib/postgresql/.pgpass',
    content => "${management_ip}:${mid}:${replicator_password}",
    tag     => 'pgpass',
  }
  @@concat::fragment { "postgres replication ${::hostname}":
    target  => '/var/lib/postgresql/.pgpass',
    content => "${::hostname}:${mid}:${replicator_password}",
    tag     => 'pgpass',
  }
  concat::fragment { 'postgres /var/lib comment-hack':
    target  => '/var/lib/postgresql/.pgpass',
    content => '# Comment hack, to ensure that the file exists',
  }

  @@concat::fragment { "postgres postgres ${management_ip}":
    target  => '/root/.pgpass',
    content => "${management_ip}:${database_port}:*:postgres:${password}",
    tag     => 'pgpass',
  }
  @@concat::fragment { "postgres postgres ${::hostname}":
    target  => '/root/.pgpass',
    content => "${::hostname}:${database_port}:*:postgres:${password}",
    tag     => 'pgpass',
  }
  concat::fragment { 'postgres /root comment-hack':
    target  => '/root/.pgpass',
    content => '# Comment hack, to ensure that the file exists',
  }

  Concat::Fragment <<| tag == 'pgpass'  |>>
}
