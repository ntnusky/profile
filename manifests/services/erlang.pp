# Module to install erlang from Erlangs repositories
class profile::services::erlang {
  apt::source { 'erlang':
    location   => 'https://packages.erlang-solutions.com/ubuntu',
    repos      => 'contrib',
    key_source => 'https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc',
    before     => Package['erlang'],
  }

  package { 'erlang':
    ensure => '1:19.3-1',
  }
}
