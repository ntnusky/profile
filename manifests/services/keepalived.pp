# This class installs the keepalived daemon and configures the system to allow
# processes to bind to addresses not yet owned by the system.
class profile::services::keepalived {
  # Make sure to restart keepalived whenever its configuration changes.
  Concat['/etc/keepalived/keepalived.conf'] ~> Service['keepalived']

  # Install keepalived
  include ::keepalived

  # Open the firewall for vrrp traffic
  firewall { '020 accept vrrp':
    proto       => 'vrrp',
    destination => '224.0.0.18',
    action      => 'accept',
  }


  # Enable bindings to ip's not present on the machine, so that the
  # services can bind to keepalived addresses.
  sysctl::value { 'net.ipv4.ip_nonlocal_bind':
    value => '1',
  }
  sysctl::value { 'net.ipv6.ip_nonlocal_bind':
    value => '1',
  }

  # As keepalived has startproblems at boot, restart it 15 seconds after boot.
  cron { 'restart_keepalived':
    ensure  => 'present',
    command => '/bin/sleep 15; /bin/systemctl restart keepalived.service',
    user    => 'root',
    special => 'reboot',
  }
}
