# Installs and configures a rabbitmq server for our openstack environment.
class profile::services::rabbitmq {
  # VRRP information
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::rabbitmq::vrrp::id')
  $vrpri = hiera('profile::rabbitmq::vrrp::priority')

  # Rabbit credentials
  $rabbituser = hiera('profile::rabbitmq::rabbituser')
  $rabbitpass = hiera('profile::rabbitmq::rabbitpass')
  $secret     = hiera('profile::rabbitmq::rabbitsecret')

  # Controller information
  $if_management = hiera('profile::interfaces::management')
  $ctrlnodes  = hiera('controller::names')

  # Rabbit IP
  $rabbit_ip = hiera('profile::rabbitmq::ip')

  # Make sure keepalived is installed before rabbit.
  require ::profile::services::keepalived

  # Configure the correct repo, install rabbitmq and create users.
  $rabbitUrl = 'https://bintray.com/rabbitmq/Keys/download_file'
  $rabbitArg = 'file_path=rabbitmq-release-signing-key.asc'
  apt_key { 'rabbitmq-release-key':
    ensure => 'present',
    id     => '0A9AF2115F4687BD29803A206B73A36E6026DFCA',
    source => "${rabbitUrl}?${rabbitArg}",
  }->
  class { '::rabbitmq':
    erlang_cookie            => $secret,
    wipe_db_on_cookie_change => true,
  }->
  rabbitmq_user { $rabbituser:
    admin    => true,
    password => $rabbitpass,
    provider => 'rabbitmqctl',
  } ->
  rabbitmq_user_permissions { "${rabbituser}@/":
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }

  # Install munin plugins for monitoring.
  munin::plugin { 'rabbit_fd':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/rabbit_fd',
    config => ['user root'],
  }
  munin::plugin { 'rabbit_processes':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/rabbit_processes',
    config => ['user root'],
  }
  munin::plugin { 'rabbit_memory':
    ensure => present,
    source => 'puppet:///modules/profile/muninplugins/rabbit_memory',
    config => ['user root'],
  }

  # Configure rabbitmq to be alowed more than 1024 file descriptors using
  # systemd.
  file { '/etc/systemd/system/rabbitmq-server.service.d':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
  ini_setting { 'Rabbit files':
    ensure  => present,
    path    => '/etc/systemd/system/rabbitmq-server.service.d/limits.conf',
    section => 'Service',
    setting => 'LimitNOFILE',
    value   => '16384',
    notify  => Exec['rabbitmq-systemd-reload'],
    require => File['/etc/systemd/system/rabbitmq-server.service.d'],
  }
  exec { 'rabbitmq-systemd-reload':
    command     => '/bin/systemctl daemon-reload',
    notify      => Service['rabbitmq-server'],
    refreshonly => true,
  }

  # Include rabbitmq configuration for sensu. And the plugin
  include ::profile::services::rabbitmq::sensu
  include ::profile::sensu::plugin::rabbitmq

  # Configure keepalived
  keepalived::vrrp::script { 'check_rabbitmq':
    script =>
      "bash -c '[[ $(/usr/sbin/rabbitmqctl status | grep -c rabbit) -ge 2 ]]'",
  }
  keepalived::vrrp::instance { 'public-rabbitmq':
    interface         => $if_management,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${rabbit_ip}/32",
    ],
    track_script      => 'check_rabbitmq',
  }
}
