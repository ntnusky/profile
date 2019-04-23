# Configure firewall for redis servers
class profile::services::redis::firewall {
  ::profile::baseconfig::firewall::service::infra { 'Redis':
    protocol => 'tcp',
    port     => 6379,
  }
  ::profile::baseconfig::firewall::service::infra { 'Redis-sentinel':
    protocol => 'tcp',
    port     => 26379,
  }
}
