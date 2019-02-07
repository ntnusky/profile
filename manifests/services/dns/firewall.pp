# This class configures firewall rules for DNS 
class profile::services::dns::firewall {
  ::profile::baseconfig::firewall::service::global { 'TCP DNS':
    port     => 53,
    protocol => 'tcp',
  }
  ::profile::baseconfig::firewall::service::global { 'UDP DNS':
    port     => 53,
    protocol => 'udp',
  }
}
