# Install and configure uchiwa and the apache vhost for it
class profile::sensu::uchiwa {

  require ::profile::services::apache

  $password = hiera('profile::sensu::uchiwa::password')
  $api_name = hiera('ntnuopenstack::region')
  $uchiwa_url = hiera('profile::sensu::uchiwa::fqdn')

  $management_netv6 = hiera('profile::networks::management::ipv6::prefix', false)
  $management_if = hiera('profile::interfaces::management')
  $management_ipv4 = $::facts['networking']['interfaces'][$management_if]['ip']

  $private_key = hiera('profile::sensu::uchiwa::private_key')
  $public_key  = hiera('profile::sensu::uchiwa::public_key')
  $private_key_path = '/etc/sensu/keys/uchiwa.rsa'
  $public_key_path  = '/etc/sensu/keys/uchiwa.rsa.pub'

  if ( $management_netv6 ) {
    $management_ipv6 = $::facts['networking']['interfaces'][$management_if]['ip6']
  } else {
    $management_ipv6 = ''
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

  apache::vhost { "${uchiwa_url} http":
    servername          => $uchiwa_url,
    serveraliases       => [$uchiwa_url],
    port                => 80,
    ip                  => concat([], $management_ipv4, $management_ipv6),
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
      'cookie',
    ],
  }

}
