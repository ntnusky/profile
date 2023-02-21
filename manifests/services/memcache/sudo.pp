# sudo config for memcache administration
class profile::services::memcache::sudo {
  sudo::conf { 'memcache':
    priority => 50,
    source   => 'puppet:///modules/profile/sudo/memcache_sudoers',
  }
}
