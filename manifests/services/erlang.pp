# Module to install erlang from Erlangs repositories
class profile::services::erlang {
  $version = lookup('profile::services::erlang::version', {
    'default_value' => '1:23.3.1-1',
  })
  apt::source { 'erlang':
    comment  => '',
    location => 'https://packages.erlang-solutions.com/ubuntu',
    repos    => 'contrib',
    key      => {
      id     => '434975BD900CCBE4F7EE1B1ED208507CA14F4FCA',
      source => 'https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc',
    },
    notify   => Exec['apt_update'],
    before   => Apt::Pin['erlang'],
  }

  apt::pin { 'erlang':
    packages => 'erlang*',
    version  => $version,
    priority => 1000,
  }
}
