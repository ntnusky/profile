# This definition collects interface configuration from hiera, and configures
# the interface according to these settings.
define setDHCP {
  $method = hiera("profile::interfaces::${name}::method")
  $address = hiera("profile::interfaces::${name}::address", false)
  $netmask = hiera("profile::interfaces::${name}::netmask", '255.255.255.0')

  $mysql_master = hiera('profile::mysqlcluster::master')

  network::interface{ $name:
    method  => $method,
    address => $address,
    netmask => $netmask,
  }
}

# This class provides basic configuration of our hosts. Sets up NTP, installs
# some base utilities, configures networking and so fort.
class profile::baseconfig {
  $environment = hiera('profile::puppet::environment')
  if($::bios_vendor == 'HP') {
    include ::hpacucli
  }

  package { [
    'atop',
    'bc',
    'ethtool',
    'fio',
    'git',
    'gdisk',
    'htop',
    'iotop',
    'iperf3',
    'locate',
    'pwgen',
    'qemu-utils',
    'screen',
    'sysstat',
    'tcpdump',
    'vim',
  ] :
    ensure => 'present',
  }

  # This check were supposed to not install nmap on the galera master, as the
  # galera module ensures namp is installed on this node. It did not work as
  # intended, and should be fixed at some point if one want nmap on all nodes.
  #
  #if($::fqdn != $mysql_master) {
  #  package { 'nmap':
  #    ensure => 'latest',
  #    }
  #}

  class { '::ntp':
    servers  => [ 'ntp.hig.no'],
    restrict => [
      'default kod nomodify notrap nopeer noquery',
      '-6 default kod nomodify notrap nopeer noquery',
    ],
  }

  # If we are running on ubuntu 14.04, add the puppet repos to get puppet 3.8.
  if ($::lsbdistcodename == 'trusty') {
    apt::source { 'puppetlabs':
      location   => 'http://apt.puppetlabs.com',
      repos      => 'main',
      key        => '1054B7A24BD6EC30',
      key_server => 'pgp.mit.edu',
      before     => Package['puppet'],
    }
  }
  
  package { 'puppet':
    ensure => 'present',
  }

  ini_setting { 'Puppet Start':
    ensure  => present,
    path    => '/etc/default/puppet',
    section => '',
    setting => 'START',
    value   => 'yes',
    require => Package['puppet'],
  }

  # This environment is not the one really used, as that is decided by
  # foreman's ENC, but puppet gets really sad if this setting points to a
  # non-existent environment. This setting might also get useful in the cases
  # where an ENC  is not used.
  ini_setting { 'Puppet environment':
    ensure  => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'agent',
    setting => 'environment',
    value   => $environment,
    notify  => Service['puppet'],
    require => Package['puppet'],
  }

  service { 'puppet':
    ensure  => 'running',
    require => Package['puppet'],
  }

  # If the puppet-version is new enough to support ecda ssh-keys (which is
  # default in openssh these days), configure ssh. If puppet is too old; it
  # should be updated so that ssh gets configured... :)
  if ($::puppetversion > '3.5.0') {
    class {'::ssh':
      server_options => {
        'Match User nova' => {
          'HostbasedAuthentication' => 'yes',
        },
      },
      client_options => {
        'Host *' => {
          'HostbasedAuthentication' => 'yes',
          'EnableSSHKeysign'        => 'yes',
          'HashKnownHosts'          => 'yes',
          'SendEnv'                 => 'LANG LC_*',
        },
      },
    }

    exec {'shosts.equiv':
      command => 'cat /etc/ssh/ssh_known_hosts | grep -v "^#" | \
                  awk \'{print $1}\' | sed -e \'s/,/\n/g\' > \
                  /etc/ssh/shosts.equiv',
      path    => '/bin:/usr/bin',
      require => Class['ssh::knownhosts'],
    }
  }

  # Configure interfaces as instructed in hiera.
  $interfacesToConfigure = hiera('profile::interfaces', false)
  if($interfacesToConfigure) {
    setDHCP { $interfacesToConfigure: }
  }
}
