# Configures useful aliases for a certain user.
define profile::baseconfig::alias (
  String $username = $name,
) {
  if($username == 'root') {
    $filename = '/root/.bash_aliases'
  } else {
    $filename = "/home/${username}/.bash_aliases"
  }

  file { $filename:
    ensure => present,
    owner => $username, 
    mode  => '0644',
  }

  $caserver = lookup('profile::puppet::caserver')
  file_line { "Alias pca for ${username}":
    path    => $filename,
    line    => "alias pca='sudo puppet agent --test --server ${caserver}'",
    require => File[$filename],
  }
  file_line { "Alias pat for ${username}":
    path    => $filename,
    line    => "alias pat='sudo puppet agent --test'",
    require => File[$filename],
  }
}
