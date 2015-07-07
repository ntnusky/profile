# Reverse proxy for Kibana, Icinga, OpenTSDB
class profile::monitoring::reverseproxy {

  $kibana_vhost = hiera('profile::monitoring::kibana_vhost')
  $data_password = hiera('profile::monitoring::data_password')
  $nginx_key = hiera('profile::keys::nginx')

  include ::nginx

  file { '/etc/nginx/ssl':
    ensure => directory,
  } ->
  file { '/etc/nginx/ssl/nginx.key':
    ensure  => file,
    content => "${nginx_key}",
  } ->
  file { '/etc/nginx/ssl/nginx.crt':
    ensure => file,
    source => 'puppet:///modules/profile/keys/certs/nginx.crt',
  } ->
  htpasswd { 'data':
    username    => 'data',
    cryptpasswd => ht_crypt("${data_password}",'aB'),
    target      => '/etc/nginx/htpasswd.users',
  }
  nginx::resource::vhost { "${kibana_vhost}":
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
    vhost    => "${kibana_vhost}",
    location => '/',
    ssl      => true,
    ssl_only => true,
    proxy    => 'http://localhost:5601',
  }

}

