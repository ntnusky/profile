# Keepalived configuration for rabbitmq
class profile::services::keepalived::rabbitmq {

  require ::profile::services::keepalived

  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $v4id = hiera('profile::rabbitmq::ipv4::id')
  $v4pri = hiera('profile::rabbitmq::ipv4::priority')
  $v4ip = hiera('profile::rabbitmq::ipv4')
  $v6id = hiera('profile::rabbitmq::ipv6::id',false)
  $v6pri = hiera('profile::rabbitmq::ipv6::priority',false)
  $v6ip = hiera('profile::rabbitmq::ipv6',false)
  $vrinterval = hiera('profile::rabbitmq::vrrp::interval',2)
  $if_management = hiera('profile::interfaces::management')


  keepalived::vrrp::script { 'check_rabbitmq':
    script   =>
      "bash -c '[[ $(/usr/sbin/rabbitmqctl status | grep -c rabbit) -ge 2 ]]'",
    interval => $vrinterval,
  }
  keepalived::vrrp::instance { 'public-rabbitmq':
    interface         => $if_management,
    state             => 'MASTER',
    virtual_router_id => $v4id,
    priority          => $v4pri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${v4ip}/32",
    ],
    track_script      => 'check_rabbitmq',
  }
  if ($v6ip) {
    keepalived::vrrp::instance { 'public-rabbitmq-ipv6':
      interface         => $if_management,
      state             => 'MASTER',
      virtual_router_id => $v6id,
      priority          => $v6pri,
      auth_type         => 'PASS',
      auth_pass         => $vrrp_password,
      virtual_ipaddress => [
        "${v6ip}/64",
      ],
      track_script      => 'check_rabbitmq',
    }
  }
}
