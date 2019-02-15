#Configures the firewall for the postgres servers
class profile::services::postgresql::firewall {
  ::profile::baseconfig::firewall::service::infra { 'Postgres':
    protocol => 'tcp',
    port     => 5432,
  }
}
