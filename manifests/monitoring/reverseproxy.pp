# Reverse proxy for Kibana, Icinga, OpenTSDB
class profile::monitoring::reverseproxy {

  include nginx

  file { '/etc/nginx/ssl':
    ensure => directory
  } ->
  file { '/etc/nginx/ssl/nginx.key':
    source        => 'puppet:///modules/profile/keys/private/nginx.key'
  } ->
  file { '/etc/nginx/ssl/nginx.crt':
    source       => 'puppet:///modules/profile/keys/certs/nginx.crt'
  } ->

  nginx::resource::vhost { '172.17.1.12':
    listen_port    => 8081,
    ssl_port       => 8081,
    ssl            => true,
    ssl_key        => '/etc/nginx/ssl/nginx.key'
    ssl_cert       => '/etc/nginx/ssl/nginx.crt'
    proxy_redirect => 'http://localhost:5601',
  }

}

