# Installs the dashboard code. Useful for the dashboard-clients which are
# distributed alongside the dashboard.
class profile::services::dashboard::install::onlycode {
  vcsrepo { '/opt/machineadmin-code':
    ensure   => latest,
    provider => git,
    source   => 'git://git.rothaugane.com/machineadmin.git',
    revision => 'master',
  }
}
