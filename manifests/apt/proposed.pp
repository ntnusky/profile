# Enabled the apt-proposed repositories with a low priority, so that some
# packages can be installed from it.
class profile::apt::proposed {
  $distro = lookup('profile::apt::proposed::distro', {
    'default_value' => $::facts['os']['distro']['codename'], 
    'value_type'    => Integer,
  })
  $pin = lookup('profile::apt::proposed::pin', {
    'default_value' => 400, 
    'value_type'    => Integer,
  })

  apt::source { 'ubuntu-proposed':
    location => 'http://archive.ubuntu.com/ubuntu/',
    release  => "${distro}-proposed"
    repos    => 'main universe',
    pin      => 400,
  }
}
