# This class ensures that all baseconfiguration are brought in.
class profile::baseconfig {
  include ::profile::baseconfig::disk
  include ::profile::baseconfig::facts
  include ::profile::baseconfig::git
  include ::profile::baseconfig::ioscheduler
  include ::profile::baseconfig::logging
  include ::profile::baseconfig::logrotate
  include ::profile::baseconfig::mounts
  include ::profile::baseconfig::motd
  include ::profile::baseconfig::networking
  include ::profile::baseconfig::ntp
  include ::profile::baseconfig::packages
  include ::profile::baseconfig::puppet
  include ::profile::baseconfig::ssh
  include ::profile::baseconfig::sudo
  include ::profile::baseconfig::updates

  include ::profile::utilities::ntnuskytools

  include ::profile::zabbix::agent

  # If duo should be installed, install and configure it. 
  $installduo = lookup('profile::duo::enabled', {
    'default_value' => false,
    'value_type'    => Boolean,
  })
  if($installduo) {
    include ::profile::baseconfig::duo
  }

  # Optionally install the SL2 client 
  $installsl2client = lookup('profile::shiftleader::client::install', {
    'default_value' => false,
    'value_type'    => Boolean,
  })
  if ($installsl2client) {
    include ::shiftleader::client
  }

  # If the machine is a physical machine, install ipmitool and hw-mgmt-tools
  if($facts['is_virtual'] == false) {
    include ::profile::utilities::ipmitool
    include ::profile::utilities::machinetools
  }
}
