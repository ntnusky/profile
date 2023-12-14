# This class installs and configures the postgresql server
class profile::services::postgresql::server {
  # TODO: Stop looking for the management-IP in hiera, and simply just take it
  # from SL.
  $mif = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
    'value_type'    => String,
  })
  $ip = lookup("profile::baseconfig::network::interfaces.${mif}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $facts['networking']['interfaces'][$mif]['ip'],
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

  $keepalived = lookup('profile::postgres::keepalived::enable', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  $postgres_version = lookup('profile::postgres::version', {
    'default_value' => '9.6',
    'value_type'    => String,
  })

  $max_connections = lookup('profile::postgres::max_connections', {
    'default_value' => 250,
    'value_type'    => Integer,
  })

  include ::profile::services::postgresql::pghba
  include ::profile::services::postgresql::pgpass
  include ::profile::services::postgresql::scripts

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

  # If the IP defined to be the postgres-IP is the same as the hosts own IP,
  # just install postgres as normal.
  if($ip == $postgresql_ipv4 or ! $keepalived) {
    $vips = []

  # If the IP defined to be the postgres-IP differs from the hosts own IP,
  # install keepalived to manage the postgres-IP. 
  } else {
    contain profile::services::postgresql::keepalived
    $vips = concat([$postgresql_ipv4], $postgresql_ipv6)
  }

  class { '::postgresql::globals':
    manage_package_repo => true,
    version             => $postgres_version,
  }

  $ips = concat($vips, '127.0.0.1', '::1', $ip)

  class { '::postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => join($ips, ','),
    port                       => $database_port,
    postgres_password          => $confpassword,
    manage_pg_ident_conf       => false,
    log_line_prefix            => '%m [%p] %q%u@%d ',
  }

  class { '::postgresql::server::contrib': }

  postgresql::server::config_entry {
    'checkpoint_segments': ensure => 'absent';
    'max_connections':     value  => $max_connections;
    'max_wal_senders':     value  => '3';
    'wal_level':           value  => 'hot_standby';
  }

  if(versioncmp($postgres_version, '13') >= 0) {
    postgresql::server::config_entry {
      'wal_keep_size':        value => '128';
      'promote_trigger_file': value => '/var/lib/postgresql/13/main/triggerfile';
    }
  } else {
    postgresql::server::config_entry { 'wal_keep_segments': value  => '8'; }
  }
}
