# installs the python-memchace client
class profile::services::memcache::pythonclient {
  ensure_packages ( ['python-memcache'], {
    'ensure' => 'present',
  })
}
