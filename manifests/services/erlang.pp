# Module to install erlang from Erlangs repositories
class profile::services::erlang {
  apt::source { 'erlang':
    location   => 'https://packages.erlang-solutions.com/ubuntu',
    repos      => 'contrib',
    key        => '434975BD900CCBE4F7EE1B1ED208507CA14F4FCA',
    key_source => 'https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc',
    notify     => Exec['apt_update'],
    before     => Apt::Pin['erlang'],
  }

  apt::pin { 'erlang':
    packages => 'erlang*',
    version  => '1:19.3-1',
    priority => 1000,
  }
}
