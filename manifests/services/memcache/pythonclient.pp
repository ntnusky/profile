# installs the python-memchace client
class profile::services::memcache::pythonclient {
  $install = hiera('profile::memcache::pythonclient::install', true)
  if $install {
    ensure_packages ( ['python-memcache'], {
      'ensure' => 'present',
    })
  }
}
