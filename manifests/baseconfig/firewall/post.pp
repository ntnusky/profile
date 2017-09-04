# This class installs and configures firewall post.
class profile::baseconfig::firewall::post {
  $action = hiera('profile::firewall::action::final', 'drop')

  firewall { '999 drop all':
    proto  => 'all',
    action => $action,
    before => undef,
  }
}
