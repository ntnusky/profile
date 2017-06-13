# Module to install erlang from Erlangs repositories
class profile::services::erlang {
  apt::source { 'erlang':
    location   => 'https://packages.erlang-solutions.com/ubuntu',
    repos      => 'contrib',
    key_source => 'https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc',
    before     => Apt::Pin['erlang'],
  }

  apt::pin { 'erlang':
    packages => 'erlang*',
    version  => '1:19.3-1',
    priority => 1000,
  }
}
