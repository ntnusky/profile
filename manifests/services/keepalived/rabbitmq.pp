# Keepalived configuration for rabbitmq
class profile::services::keepalived::rabbitmq {

  require ::profile::services::keepalived

  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::rabbitmq::vrrp::id')
  $vrpri = hiera('profile::rabbitmq::vrrp::priority')
  $vrinterval = hiera('profile::rabbitmq::vrrp::interval',2)
  $if_management = hiera('profile::interfaces::management')
  $rabbit_ip = hiera('profile::rabbitmq::ip')


  keepalived::vrrp::script { 'check_rabbitmq':
    script   =>
      "bash -c '[[ $(/usr/sbin/rabbitmqctl status | grep -c rabbit) -ge 2 ]]'",
    interval => $vrinterval,
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
