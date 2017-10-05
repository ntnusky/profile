# This class ensures that all baseconfiguration are brought in.
class profile::baseconfig {
  include ::profile::baseconfig::firewall
  include ::profile::baseconfig::networking
  include ::profile::baseconfig::ntp
  include ::profile::baseconfig::packages
  include ::profile::baseconfig::puppet
  include ::profile::baseconfig::ssh
  include ::profile::baseconfig::sudo
  include ::profile::baseconfig::unattendedupgrades

  $installmunin = hiera('profile::munin::install', true)
  if($installmunin) {
    include ::profile::munin::node
  }

  $installsensu = hiera('profile::sensu::install', true)
  if ($::hostname != 'monitor' and $installsensu) {
    include ::profile::sensu::client
  }

  # The ping vg hack is not needed anymore, as we now use multiple routing
  # tables.
  cron { 'gwrefresh':
    ensure => absent,
  }
}
