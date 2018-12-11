# Installs the dashboard
class profile::services::dashboard::install::code {
  $revision = lookup('profile::dashboard::revision', {
    'value_type' => 'String',
    'default_value' => 'master',
  })

  vcsrepo { '/opt/shiftleader':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/ntnusky/shiftleader.git',
    revision => $revision,
  }
}
