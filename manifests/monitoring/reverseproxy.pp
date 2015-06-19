# Reverse proxy for Kibana, Icinga, OpenTSDB
class profile::monitoring::reverseproxy {

  include nginx

  nginx::resource::vhost { '172.17.1.12':
    listen_port    => 8081,
    ssl_port       => 8081,
    ssl            => true,
    proxy_redirect => 'http://localhost:5601',
  }

}

