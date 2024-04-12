# This class configures the firewall to permit incoming OMAPI-requests
class profile::services::dhcp::firewall::omapi {
  ::profile::baseconfig::firewall::service::infra { 'DHCP OMAPI':
    protocol => 'tcp',
    port     => 7911,
  }
}
