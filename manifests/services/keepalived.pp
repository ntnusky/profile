# This class installs the keepalived daemon and configures the system to allow
# processes to bind to addresses not yet owned by the system.
class profile::services::keepalived {
  # Make sure to restart keepalived whenever its configuration changes.
  Concat['/etc/keepalived/keepalived.conf'] ~> Service['keepalived']

  # Install keepalived
  include ::keepalived

  # Enable bindings to ip's not present on the machine, so that the
  # services can bind to keepalived addresses.
  sysctl::value { 'net.ipv4.ip_nonlocal_bind':
    value => '1',
  }
}
