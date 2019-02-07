# Configures the firewall for puppetmasters. 
class profile::services::puppet::db::firewall {
  ::profile::baseconfig::firewall::service::infra { 'PuppetDB':
    protocol => 'tcp',
    port     => 8081,
  }
}
