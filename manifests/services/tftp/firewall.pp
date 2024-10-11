# This class configures firewall rules for TFTP
class profile::services::tftp::firewall {
  # TFTP also uses higher-numbered ports for the actual data-transfer; but this
  # is handled by the defult allow ESTABLISHED incoming rule from baseconfig.
  ::profile::firewall::infra::all { 'TFTP':
    port               => 69,
    transport_protocol => 'udp',
  }
}
