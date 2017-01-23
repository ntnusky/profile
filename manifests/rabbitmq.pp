# Installs and configures a rabbitmq server for our openstack environment.
class profile::rabbitmq {
  $if_management = hiera('profile::interfaces::management')
  $rabbit_ip = hiera('profile::rabbitmq::ip')
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::rabbitmq::vrrp::id')
  $vrpri = hiera('profile::rabbitmq::vrrp::priority')

  $rabbituser = hiera('profile::rabbitmq::rabbituser')
  $rabbitpass = hiera('profile::rabbitmq::rabbitpass')
  $secret     = hiera('profile::rabbitmq::rabbitsecret')
  $ctrlnodes  = hiera('controller::names')

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
    before               => Anchor['profile::rabbitmq::end'],
  }

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
    value   => '300000',
    notify  => Exec['rabbitmq-systemd-reload'],
    require => File['/etc/systemd/system/rabbitmq-server.service.d'],
  }

  exec { 'rabbitmq-systemd-reload':
    command     => '/usr/bin/systemctl daemon-reload',
    notify      => Service['rabbitmq-server'],
    refreshonly => true,
  }

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
  anchor { 'profile::rabbitmq::end' :
    require => [Keepalived::Vrrp::Instance['public-rabbitmq'],
              Keepalived::Vrrp::Script['check_rabbitmq']],
  }
}
