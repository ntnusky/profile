# This class installs and configures the postgresql server 
class profile::services::postgresql::server {
  $management_if = hiera('profile::interfaces::management')
  $management_ip = hiera("profile::interfaces::${management_if}::address")
  $database_port = hiera('profile::postgres::backend::port', '5433')
  $password = hiera('profile::postgres::password')
  $replicator_password = hiera('profile::postgres::replicatorpassword')
  $master_server = hiera('profile::postgres::masterserver')

  class { '::postgresql::globals':
    manage_package_repo => true,
    version             => '9.6',
  }

  class { '::postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => $management_ip,
    port                       => scanf($database_port, '%i')[0],
    postgres_password          => $password,
    manage_pg_ident_conf       => false,
  }

  postgresql::server::role { 'replicator':
    password_hash => postgresql_password('replicator', $replicator_password),
    replication   => true,
  }

  postgresql::server::config_entry { 'wal_level':
    value => 'hot_standby',
  }

  postgresql::server::config_entry { 'max_wal_senders':
    value => '3',
  }

  postgresql::server::config_entry { 'checkpoint_segments':
    ensure => 'absent',
  }

  postgresql::server::config_entry { 'wal_keep_segments':
    value => '8',
  }

  if($::fqdn != $master_server) {
    postgresql::server::config_entry { 'hot_standby':
      value => 'on',
    }
  }

  @@postgresql::server::pg_hba_rule { "allow ${management_ip} for replication":
    description => "Open up PostgreSQL for access from ${management_ip}",
    type        => 'hostssl',
    database    => 'replication',
    user        => 'replicator',
    address     => $management_ip,
    auth_method => 'md5',
  }

  Postgresql::Server::Pg_hba_rule <<| |>>

  class { '::postgresql::server::contrib': }
}
