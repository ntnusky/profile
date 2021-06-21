# Install and configure uchiwa and the apache vhost for it
class profile::sensu::uchiwa {

  require ::profile::services::apache

  $password = lookup('profile::sensu::uchiwa::password', String)
  $api_name = lookup('ntnuopenstack::region', String)
  $uchiwa_url = lookup('profile::sensu::uchiwa::fqdn', Stdlib::Fqdn)

  $management_netv6 = lookup('profile::networks::management::ipv6::prefix', {
    'value_type'    => Variant[Stdlib::IP::Address::V6::CIDR, Boolean],
    'default_value' => false,
  })
  $management_if = lookup('profile::interfaces::management', {
    'value_type'    => Variant[String, Boolean],
    'default_value' => false,
  })
  $mip = $facts['networking']['interfaces'][$management_if]['ip']
  $management_ipv4 = lookup("profile::baseconfig::network::interfaces.${management_if}.ipv4.address", {
    'value_type'    => Stdlib::IP::Address::V4,
    'default_value' => $mip,
  })

  $private_key = lookup('profile::sensu::uchiwa::private_key', String)
  $public_key  = lookup('profile::sensu::uchiwa::public_key', String)
  $private_key_path = '/etc/sensu/keys/uchiwa.rsa'
  $public_key_path  = '/etc/sensu/keys/uchiwa.rsa.pub'

  $register_loadbalancer = lookup('profile::haproxy::register', {
    'value_type'    => Boolean,
    'default_value' => True,
  })

  if ( $management_netv6 ) {
    $management_ipv6 = $::facts['networking']['interfaces'][$management_if]['ip6']
    $ip = concat([], $management_ipv4, $management_ipv6)
  } else {
    $ip = [$management_ipv4]
  }

  class { '::uchiwa':
    user                => 'sensu',
    pass                => $password,
    install_repo        => false,
    sensu_api_endpoints => [{
      name    => $api_name,
      user    => '',
      pass    => '',
      timeout => 10,
    }],
    auth                => {
      'publickey'  => $public_key_path,
      'privatekey' => $private_key_path,
    },
  }

  include ::apache::mod::proxy
  include ::apache::mod::proxy_html

  apache::vhost { "${uchiwa_url}-http":
    servername          => $uchiwa_url,
    serveraliases       => [$uchiwa_url],
    port                => 80,
    ip                  => $ip,
    docroot             => false,
    manage_docroot      => false,
    access_log_format   => 'forwarded',
    proxy_preserve_host => true,
    proxy_pass          => [
      {
        'path' => '/',
        'url'  => 'http://127.0.0.1:3000/',
      },
      {
        'path' => '/socket.io/1/websocket',
        'url'  => 'ws://127.0.0.1:3000/socket.io/1/websocket',
      },
      {
        'path' => '/socket.io/',
        'url'  => 'http://127.0.0.1:3000/socket.io/',
      },
    ],
    custom_fragment     => '
    ProxyHTMLEnable On
    ProxyHTMLURLMap http://127.0.0.1:3000/ /',
  }

  file { '/etc/sensu/keys':
    ensure => directory,
    owner  => 'uchiwa',
    group  => 'uchiwa',
    mode   => '0700',
  }

  file { $private_key_path:
    ensure  => file,
    owner   => 'uchiwa',
    group   => 'uchiwa',
    mode    => '0600',
    content => $private_key,
    require => File['/etc/sensu/keys'],
    notify  => Service[$uchiwa::service_name],
  }

  file { $public_key_path:
    ensure  => file,
    owner   => 'uchiwa',
    group   => 'uchiwa',
    mode    => '0644',
    content => $public_key,
    require => File['/etc/sensu/keys'],
    notify  => Service[$uchiwa::service_name],
  }

  if($register_loadbalancer) {
    profile::services::haproxy::tools::register { "Uchiwa-${::fqdn}":
      servername  => $::hostname,
      backendname => 'bk_uchiwa',
    }

    @@haproxy::balancermember { $::fqdn:
      listening_service => 'bk_uchiwa',
      ports             => '80',
      ipaddresses       => $management_ipv4,
      server_names      => $::hostname,
      options           => [
        'check inter 5s',
      ],
    }
  }
}
