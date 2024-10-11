#Configures the firewall for the postgres servers
class profile::services::postgresql::firewall {
  ::profile::firewall::infra::region { 'Postgres':
    port => 5432,
  }
}
