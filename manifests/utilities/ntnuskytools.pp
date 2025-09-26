# Install our homemade administration scripts
class profile::utilities::ntnuskytools {

  $repo_source = lookup('profile::utilities::ntnuskytools::repo', {
    'default_value' => 'https://git.ntnu.no/ntnusky/tools.git',
    'value_type'    => String
  })

  file { '/usr/ntnusky':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0770',
  }
  vcsrepo { '/usr/ntnusky/tools':
    ensure   => latest,
    force    => true,
    provider => git,
    source   => $repo_source,
    revision => master,
    require  => File['/usr/ntnusky'],
  }
}
