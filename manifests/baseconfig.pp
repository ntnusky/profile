# This class ensures that all baseconfiguration are brought in.
class profile::baseconfig {
  include ::profile::baseconfig::disk
  include ::profile::baseconfig::firewall
  include ::profile::baseconfig::git
  include ::profile::baseconfig::ioscheduler
  include ::profile::baseconfig::logging
  include ::profile::baseconfig::logrotate
  include ::profile::baseconfig::mounts
  include ::profile::baseconfig::networking
  include ::profile::baseconfig::ntp
  include ::profile::baseconfig::packages
  include ::profile::baseconfig::puppet
  include ::profile::baseconfig::ssh
  include ::profile::baseconfig::sudo
  include ::profile::baseconfig::updates

  include ::profile::utilities::ntnuskytools

  # If duo should be installed, install and configure it. 
  $installduo = hiera('profile::duo::enabled', false)
  if($installduo) {
    include ::profile::baseconfig::duo
  }

  # If munin should be installed, install and configure the munin-node
  $installmunin = hiera('profile::munin::install', true)
  if($installmunin) {
    include ::profile::monitoring::munin::node
  }

  # If sensu should be installed, install and configure the sensu-client agent
  $installsensu = hiera('profile::sensu::install', true)
  if ($::hostname !~ /^(sensu|monitor)/ and $installsensu) {
    include ::profile::sensu::client
  }

  # If the machine is a physical machine, install ipmitool and hw-mgmt-tools
  if($facts['is_virtual'] == false) {
    include ::profile::utilities::ipmitool
    include ::profile::utilities::machinetools
  }
}
