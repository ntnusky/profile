# Add pg_hba rules to open for replication to replication-servers. 
class profile::services::postgresql::pghba {
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

  $postgres_version = lookup('profile::postgres::version', {
    'default_value' => '9.6',
    'value_type'    => String,
  })

  @@postgresql::server::pg_hba_rule { "allow ${ip} for replication":
    description => "Open up PostgreSQL for access from ${ip}",
    type        => 'host',
    database    => 'replication',
    user        => 'replicator',
    address     => "${ip}/32",
    auth_method => 'md5',
    tag         => "pghba-${postgres_version}",
  }

  Postgresql::Server::Pg_hba_rule <<| tag == "pghba-${postgres_version}" |>>
}
