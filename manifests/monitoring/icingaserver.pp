class profile::monitoring::icingaserver {
  $mysql_password = hiera('profile::monitoring::mysql_password')
  $icinga_db_password = hiera('profile::monitoring::icinga_db_password')
  $icingaweb2_db_password = hiera('profile::monitoring::icingaweb2_db_password')
  #$icingaadmin_password = hiera('profile::monitoring::icingaadmin_password')

  class { '::mysql::server':
    root_password => $mysql_password,
  } ->
  mysql::db { 'icinga2_data':
    user     => 'icinga2',
    password => $icinga_db_password,
    host     => 'localhost',
  }
  mysql::db { 'icingaweb2':
    user     => 'icingaweb2',
    password => $icingaweb2_db_password,
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
    install_mail_utils_package    => false,
  }
  package { 'heirloom-mailx':
    ensure => latest,
  }
#
# manual edits: replace last line of
# scripts/mail-service-notification.sh
# /usr/bin/printf "%b" "$template" | mail -s "$NOTIFICATIONTYPE - $HOSTDISPLAYNAME - $SERVICEDISPLAYNAME is $SERVICESTATE" -S smtp=smtp://smtp.hig.no -S from="icinga2-monitor@skyhigh.hig.no" $USEREMAIL
# scripts/mail-host-notification.sh
# /usr/bin/printf "%b" "$template" | mail -s "$NOTIFICATIONTYPE - $HOSTDISPLAYNAME is $HOSTSTATE" -S smtp=smtp://smtp.hig.no -S from="icinga2-monitor@skyhigh.hig.no" $USEREMAIL
#
# should create icinga2::object::user and usergroup, have edited email in conf.d/users.conf for now
# when creating these, again need to solve the problem with removing the default installed icingaadmin
# same as linux-servers vs linux_servers
#
# have manually removed Warning from state in service notification /etc/icinga2/conf.d/templates.conf
#
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
    display_name   => 'Load from nrpe',
    check_command  => 'nrpe',
    vars           => {
                        nrpe_command => 'check_load',
                      },
    assign_where   => '"linux_servers" in host.groups',
    ignore_where   => 'host.name == "localhost"',
    target_dir     => '/etc/icinga2/objects/applys'
  }
  icinga2::object::apply_service_to_host { 'check_swap':
    display_name   => 'Swap from nrpe',
    check_command  => 'nrpe',
    vars           => {
                        nrpe_command => 'check_swap',
                      },
    assign_where   => '"linux_servers" in host.groups',
    ignore_where   => 'host.name == "localhost"',
    target_dir     => '/etc/icinga2/objects/applys'
  }
  icinga2::object::apply_service_to_host { 'check_disk':
    display_name   => 'Disk from nrpe',
    check_command  => 'nrpe',
    vars           => {
                        nrpe_command => 'check_disk',
                      },
    assign_where   => '"linux_servers" in host.groups',
    ignore_where   => 'host.name == "localhost"',
    target_dir     => '/etc/icinga2/objects/applys'
  }
  icinga2::object::apply_service_to_host { 'check_hpacucli':
    display_name   => 'hpacucli from nrpe',
    check_command  => 'nrpe',
    vars           => {
                        nrpe_command => 'check_hpacucli',
                      },
    assign_where   => '"linux_servers" in host.groups',
    ignore_where   => 'regex("(localhost|compute0(4|5))", host.name)',
    target_dir     => '/etc/icinga2/objects/applys'
  }
  package { 'nagios-nrpe-plugin':
    ensure => latest,
  }

  class {
# should initiate the db and the webuser here, db=icingaweb2,table=icingaweb_user,{name=data,active=1,password_hash=...}
    '::icingaweb2':
      admin_users         => 'data',
      ido_db_name         => 'icinga2_data',
      ido_db_pass         => $icinga_db_password,
      ido_db_user         => 'icinga2',
      manage_apache_vhost => true;
    
#    '::icingaweb2::mod::deployment': # Dette burde være setup modulen! snodige greier...
#      auth_token => '1914a82d7da612be',
#      web_root   => '/etc/icingaweb2';
  }
# after this, have to do:
# ln -s /usr/share/icingaweb2/modules/setup /etc/icingaweb2/enabledModules/
# ./bin/icingacli setup token create
# chown icingaweb2:icingaweb2 /etc/icingaweb2/setup.token
# usermod -a -G icingaweb2 www-data
# service apache2 restart
# php.ini: date.timezone = Europe/Oslo
# chmod 775 /etc/icingaweb2
# må config'e alt manuelt fra setup gui etterpå samt for å fullføre:
# chmod -R g+w /etc/icingaweb2/*  
}
