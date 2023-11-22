# Installs and configures a DHCP server.
class profile::services::dhcp {
  include ::profile::services::dhcp::firewall
  include ::profile::services::dhcp::pools
  include ::profile::services::dhcp::server

  $sl2 = lookup('profile::shiftleader::major::version', {
    'default_value' => 1,
    'value_type'    => Integer,
  })

  # If we use shiftleader1 we need to allow for external OMAPI requests from the
  # shiftleader servers.
  if($sl2 == 1) {
    include ::profile::services::dhcp::firewall::omapi

  # If we run a newer variant of shiftleader we need to install the 
  # worker-daemon
  } else {
    include ::shiftleader::worker::dhcp
  }
}
