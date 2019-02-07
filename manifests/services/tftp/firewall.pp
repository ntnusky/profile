# This class configures firewall rules for TFTP
class profile::services::tftp::firewall {
  # TFTP also uses higher-numbered ports for the actual data-transfer; but this
  # is handled by the defult allow ESTABLISHED incoming rule from baseconfig.
  ::profile::baseconfig::firewall::service::global { 'TFTP':
    protocol => 'udp',
    port     => 69,
  }
}
