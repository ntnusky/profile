# Installs and configures a DHCP server.
class profile::services::dhcp {
  include ::profile::services::dhcp::firewall
  include ::profile::services::dhcp::pools
  include ::profile::services::dhcp::server

  $sl_version = lookup('profile::shiftleader::major::version', {
    'default_value' => 1,
    'value_type'    => Integer,
  })

  # If we use shiftleader1 we need to allow for external OMAPI requests from the
  # shiftleader servers.
  if($sl_version == 1) {
    include ::profile::services::dhcp::firewall::omapi

  # If we run a newer variant of shiftleader we need to install the 
  # worker-daemon
  } else {
    include ::profile::services::dashboard::clients::purge
    include ::shiftleader::worker::dhcp
    include ::shiftleader::worker::dns
  }
}
