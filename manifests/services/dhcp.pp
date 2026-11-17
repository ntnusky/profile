# Installs and configures a DHCP server.
class profile::services::dhcp {
  include ::profile::services::dhcp::firewall
  include ::profile::services::dhcp::pools
  include ::profile::services::dhcp::server
  include ::shiftleader::worker::dhcp
  include ::shiftleader::worker::dns
}
