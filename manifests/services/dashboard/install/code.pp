# Installs the dashboard
class profile::services::dashboard::install::code {
  vcsrepo { '/opt/machineadmin':
    ensure   => latest,
    provider => git,
    source   => 'git://git.rothaugane.com/machineadmin.git',
    revision => 'master',
  }
}
