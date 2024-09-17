# Disables the ubuntu MOTD spam
class profile::baseconfig::motd {
  file { '/etc/default/motd-news':
    ensure  => present,
    content => join( [ '# This file is managed by puppet', 'ENABLED=0' ], "\n"),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }
}
