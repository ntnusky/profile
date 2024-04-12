# Distribute password for the root-user and the replication-user
class profile::services::postgresql::pgpass {
  # TODO: Stop looking for the management-IP in hiera, and simply just take it
  # from SL.
  if($::sl2) {
    $default = $::sl2['server']['primary_interface']['name']
  } else {
    $default = undef
  }

  $mif = lookup('profile::interfaces::management', {
    'default_value' => $default, 
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
  $password = lookup('profile::postgres::password', String)
  $replicator_password = lookup('profile::postgres::replicatorpassword', String)

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
  @@concat::fragment { "postgres replication ${ip}":
    target  => '/var/lib/postgresql/.pgpass',
    content => "${ip}:${mid}:${replicator_password}",
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

  @@concat::fragment { "postgres postgres ${ip}":
    target  => '/root/.pgpass',
    content => "${ip}:${database_port}:*:postgres:${password}",
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
