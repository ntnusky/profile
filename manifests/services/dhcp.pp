# Installs and configures a DHCP server.
class profile::services::dhcp {
  # TODO: Remove this purge at a later release
  include ::profile::services::dashboard::clients::purge

  include ::profile::services::dhcp::firewall
  include ::profile::services::dhcp::pools
  include ::profile::services::dhcp::server
  include ::shiftleader::worker::dhcp
  include ::shiftleader::worker::dns
}
