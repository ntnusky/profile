# Configures the haproxy backend for this mysql cluster member
class profile::services::mysql::haproxy::backend {
  $if = lookup('profile::interfaces::management', String)
  $autoip = $::facts['networking']['interfaces'][$if]['ip']
  $ip = lookup("profile::baseconfig::network::interfaces.${if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $autoip,
  })

  $register_loadbalancer = lookup('profile::haproxy::register', {
    'value_type'    => Boolean,
    'default_value' => True,
  })

  if($register_loadbalancer) {
    profile::services::haproxy::tools::register { "Mysql-${::fqdn}":
      servername  => $::hostname,
      backendname => 'bk_mysqlcluster',
    }

    @@haproxy::balancermember { "mysql-${::fqdn}":
      listening_service => 'bk_mysqlcluster',
      server_names      => $::hostname,
      ipaddresses       => $ip,
      ports             => '3306',
      options           => 'backup check',
    }
  }
}
