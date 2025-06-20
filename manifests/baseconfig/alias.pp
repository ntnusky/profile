# Configures useful aliases for a certain user.
define profile::baseconfig::alias (
  String $username = $name,
) {
  if($username == 'root') {
    $filename = '/root/.bash_aliases'

    concat_fragment { "Alias oppgrader in ${filename}":
      content => "alias oppgrader='apt update && DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt -y dist-upgrade && apt -y autoremove'",
      target  => $filename,
    }
  } else {
    $filename = "/home/${username}/.bash_aliases"
  }

  concat { $filename:
    ensure => present,
    owner  => $username,
    group  => ($username) ? { 'root' => 'root', default => 'users'},
    mode   => '0644',
  }

  $caserver = lookup('profile::puppet::caserver')
  concat_fragment { "Alias pca in ${filename}":
    content => "alias pca='sudo puppet agent --test --server ${caserver}'\n",
    target  => $filename,
  }
  concat_fragment { "Alias pat in ${filename}":
    content => "alias pat='sudo puppet agent --test'\n",
    target  => $filename,
  }
}
