class profile::monitoring::icingaclient {

  $management_if = hiera("profile::interfaces::management")
  $management_ip = getvar("::ipaddress_${management_if}")

  @@icinga2::object::host { $::fqdn:
    display_name     => $::fqdn,
    ipv4_address     => $management_ip,
    groups           => [['linux_servers',],],
    vars             => {
                          os           => 'linux',
                          distro       => $::operatingsystem,
    # will enable this when moving to puppet-icinga2 1.0.0 (major refactoring)
    #                      notification => {
    #                                        mail => 'groups = [ "icingaadmin" ]',
    #                                      },
                        },
    target_dir       => '/etc/icinga2/objects/hosts',
    target_file_name => "${::fqdn}.conf",
  }
  class { '::icinga2::nrpe':
    nrpe_allowed_hosts => ['172.17.1.12','127.0.0.1'],
  }
  icinga2::nrpe::command { 'check_load':
    nrpe_plugin_name => 'check_load',
    nrpe_plugin_args => '-w 15,10,5 -c 25,20,15',
  }
  icinga2::nrpe::command { 'check_swap':
    nrpe_plugin_name => 'check_swap',
    nrpe_plugin_args => '-w 90% -c 50%',
  }
  icinga2::nrpe::command { 'check_disk':
    nrpe_plugin_name => 'check_disk',
    nrpe_plugin_args => '-w 50% -c 20%',
  }

# do not use this before managing entire sudo incl what openvswitch needs!
#  sudo::conf { 'nagios':
#    content => 'nagios ALL=(ALL) NOPASSWD: /usr/lib/nagios/plugins/',
#  }

  if($::bios_vendor == 'HP') {
    file { '/usr/lib/nagios/plugins/check_hpacucli':
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/profile/icingaplugins/check_hpacucli.py',
    } ->
    icinga2::nrpe::command { 'check_hpacucli':
      nrpe_plugin_libdir => 'sudo /usr/lib/nagios/plugins',
      nrpe_plugin_name   => 'check_hpacucli',
    }
  }
}
