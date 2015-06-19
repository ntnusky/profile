# Reverse proxy for Kibana, Icinga, OpenTSDB
class profile::monitoring::reverseproxy {

  include nginx

  file { '/etc/nginx/ssl':
    ensure => directory,
  } ->
  file { '/etc/nginx/ssl/nginx.key':
    ensure => file,
    source => 'puppet:///modules/profile/keys/private/nginx.key',
  } ->
  file { '/etc/nginx/ssl/nginx.crt':
    ensure => file,
    source => 'puppet:///modules/profile/keys/certs/nginx.crt',
  } ->
  nginx::resource::vhost { '172.17.1.12':
    use_default_location => false
    listen_port          => 8081,
    ssl_port             => 8081,
    ssl                  => true,
    ssl_key              => '/etc/nginx/ssl/nginx.key',
    ssl_cert             => '/etc/nginx/ssl/nginx.crt',
    proxy               => 'http://localhost:5601',
  }
  nginx::resource::location { 'kibana' :
    vhost               => '172.17.1.12',
    location            => '/',
    proxy               => 'http://localhost:5601',
  }

}

