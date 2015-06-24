# Reverse proxy for Kibana, Icinga, OpenTSDB
class profile::monitoring::reverseproxy {

  $kibana_vhost = hiera('profile::monitoring::kibana_vhost')

  include ::nginx

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
  file { '/etc/nginx/htpasswd.users':
    ensure => file,
    source => 'puppet:///modules/profile/htpasswd.users',
  } ->
  nginx::resource::vhost { ${kibana_vhost}:
    use_default_location => false,
    listen_port          => 8081,
    ssl_port             => 8081,
    ssl                  => true,
    ssl_key              => '/etc/nginx/ssl/nginx.key',
    ssl_cert             => '/etc/nginx/ssl/nginx.crt',
    auth_basic           => 'Restricted Access',
    auth_basic_user_file => 'htpasswd.users',
  }
  nginx::resource::location { 'kibana' :
    vhost    => ${kibana_vhost},
    location => '/',
    ssl      => true,
    ssl_only => true,
    proxy    => 'http://localhost:5601',
  }

}

