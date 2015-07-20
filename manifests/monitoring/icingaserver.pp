class profile::monitoring::icingaserver {
  $mysql_password = hiera('profile::monitoring::mysql_password')
  $icinga_db_password = hiera('profile::monitoring::icinga_db_password')
  $icingaadmin_password = hiera('profile::monitoring::icingaadmin_password')

  include '::apache'
  include '::apache::mod::prefork'
  include '::apache::mod::php'
  apache::mod { 'rewrite': }

  class { '::mysql::server':
    root_password => $mysql_password,
  } ->
  mysql::db { 'icinga2_data':
    user     => 'icinga2',
    password => $icinga_db_password,
    host     => 'localhost',
  }
  
  class { '::icinga2::server':
    server_db_type                => 'mysql',
    db_host                       => 'localhost',
    db_port                       => '3306',
    db_name                       => 'icinga2_data',
    db_user                       => 'icinga2',
    db_password                   => $icinga_db_password,
    server_install_nagios_plugins => false,
    install_mail_utils_package    => true,
  }
  icinga2::object::idomysqlconnection { 'mysql_connection':
    target_dir       => '/etc/icinga2/features-enabled',
    target_file_name => 'ido-mysql.conf',
    host             => '127.0.0.1',
    port             => '3306',
    user             => 'icinga2',
    password         => $icinga_db_password,
    database         => 'icinga2_data',
    categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement',
                         'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
  }
  icinga2::object::hostgroup { 'linux_servers': }
  Icinga2::Object::Host <<| |>>

  icinga2::object::apply_service_to_host { 'check_load':
    display_name => 'Load from nrpe',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_load',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }
  icinga2::object::apply_service_to_host { 'check_swap':
    display_name => 'Swap from nrpe',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_swap',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }
  icinga2::object::apply_service_to_host { 'check_disk':
    display_name => 'Disk from nrpe',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_disk',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }
  icinga2::object::apply_service_to_host { 'check_hpacucli':
    display_name => 'hpacucli from nrpe',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_hpacucli',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }
  package { 'nagios-nrpe-plugin':
    ensure => latest,
  }  

  package { 'icinga2-classicui':
    ensure => latest,
  } ->
  htpasswd { 'icingaadmin':
    username    => 'icingaadmin',
    cryptpasswd => ht_crypt("${icingaadmin_password}",'bD'),
    target      => '/etc/icinga2-classicui/htpasswd.users',
  }
  class { '::icingaweb2':
    manage_apache_vhost => true, # fails because require Package[httpd] in 
# /etc/puppet/environments/testing/modules/apache/manifests/custom_config.pp
# from end of /etc/puppet/environments/testing/modules/icingaweb2/manifests/config.pp
# fixed with fake-httpd from equivs package
  }
}
