# Reverse proxy for Kibana, Icinga, OpenTSDB
class profile::monitoring::reverseproxy {

  include nginx

  nginx::resource::upstream { 'kibanaproxy':
    members => [
      'localhost:5601'
    ],
  }

}

