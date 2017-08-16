# This class installs and configures firewall post.
class profile::baseconfig::firewall::post {
  firewall { '999 drop all':
    proto  => 'all',
    action => 'accept',
    before => undef,
  }
}
