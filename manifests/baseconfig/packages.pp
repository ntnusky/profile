# This class installs varios basic tools.
class profile::baseconfig::packages {
  $basepackages = lookup('profile::baseconfig::packages',{
    'value_type' => Array[String],
    'merge'      => 'unique',
  })

  # Install a range of useful tools. Some mandatory; while others can be listed
  # in hiera.
  ensure_packages ( [
    'bc',
    'jq',
  ], {
    'ensure' => 'present',
  })
  ensure_packages ( $basepackages, {
    'ensure' => 'present',
  })

  # Install pip3 so that we can use it as an package-provider
  package { 'python3-pip':
    ensure => 'present',
  }

  # Install our homemade administration scripts
  file { '/usr/ntnusky':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0770',
  }
  vcsrepo { '/usr/ntnusky/tools':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/ntnusky/tools.git',
    revision => master,
    require  => File['/usr/ntnusky'],
  }
}
