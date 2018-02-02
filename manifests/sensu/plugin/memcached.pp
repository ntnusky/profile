# memcached plugin for sensu
class profile::sensu::plugin::memcached {

  require ::profile::sensu::client

  sensu::plugin { 'sensu-plugins-memcached':
    type => 'package'
  }

  package { 'libsasl2-dev':
    ensure => 'present',
    before => Sensu::Plugin['sensu-plugins-memcached'],
  }
}
