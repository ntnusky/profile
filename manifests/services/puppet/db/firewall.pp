# Configures the firewall for puppetmasters. 
class profile::services::puppet::db::firewall {
  ::profile::firewall::infra::region { 'PuppetDB':
    port => 8081,
  }
}
