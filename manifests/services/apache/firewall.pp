# This class configures firewall rules for apache port 80,443
class profile::services::apache::firewall {
  ::profile::baseconfig::firewall::service::global { 'WEB':
    protocol => 'tcp',
    port     => [80,443],
  }
}
