# This class configures the firewall, to open it for the dev-server
class profile::services::dashboard::dev::firewall {
  ::profile::baseconfig::firewall::service::management { 'Shiftleader-dev':
    port     => 8080,
    protocol => 'tcp',
  }
}
