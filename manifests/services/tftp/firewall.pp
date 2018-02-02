# This class configures firewall rules for TFTP
class profile::services::tftp::firewall {
  # TFTP also uses higher-numbered ports for the actual data-transfer; but this
  # is handled by the defult allow ESTABLISHED incoming rule from baseconfig.
  firewall { '400 accept incoming TFTP':
    proto  => 'udp',
    dport  => [69],
    action => 'accept',
  }
  require ::profile::baseconfig::firewall 
}
