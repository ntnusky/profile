# Installs the dashboard
class profile::services::dashboard::install::code {
  vcsrepo { '/opt/shiftleader':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/ntnusky/shiftleader.git',
    revision => 'master',
  }
}
