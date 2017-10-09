# This class installs and configures NTP.
class profile::baseconfig::git {
  git::config{'root-email':
    value => "root@${::fqdn}",
    user  => 'root',
    key   => 'user.email',
  }
  git::config{'root-username':
    value => 'root',
    user  => 'root',
    key   => 'user.name',
  }
}
