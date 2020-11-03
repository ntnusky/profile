# Add pg_hba rules to open for replication to replication-servers. 
class profile::services::postgresql::pghba {
  $mif = lookup('profile::interfaces::management', String)
  $ip = lookup("profile::baseconfig::network::interfaces.${mif}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $facts['networking']['interfaces'][$mif]['ip'],
  })

  @@postgresql::server::pg_hba_rule { "allow ${ip} for replication":
    description => "Open up PostgreSQL for access from ${ip}",
    type        => 'host',
    database    => 'replication',
    user        => 'replicator',
    address     => "${ip}/32",
    auth_method => 'md5',
  }

  Postgresql::Server::Pg_hba_rule <<| |>>
}
