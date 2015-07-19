class profile::monitoring::icingaclient {

  @@icinga2::object::host { $::fqdn:
    display_name     => $::fqdn,
    ipv4_address     => $::ipaddress_em1, # should be fqdn reverse lookup instead
    groups           => [['linux_servers',],],
    vars             => {
                         os     => 'linux',
                         distro => $::operatingsystem,
                        },
    target_dir       => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf",
  }

}
