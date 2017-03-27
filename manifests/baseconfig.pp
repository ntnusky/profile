# This class ensures that all baseconfiguration are brought in.
class profile::baseconfig {
  include ::profile::baseconfig::networking
  include ::profile::baseconfig::ntp
  include ::profile::baseconfig::packages
  include ::profile::baseconfig::puppet
  include ::profile::baseconfig::ssh
  include ::profile::baseconfig::sudo
  include ::profile::munin::node

  if ($::hostname != 'monitor') {
    include ::profile::sensu::client
  }

  # This is a properly ugly way to ensure that the hosts dont lose their
  # arp-entry for the gateway.
  cron { 'gwrefresh':
    command => '/bin/ping vg.no -c 1 &> /dev/null',
    user    => root,
    minute  => '*',
  }
}
