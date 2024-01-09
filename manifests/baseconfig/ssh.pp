# This class configures ssh and distributes ssh public keys.
class profile::baseconfig::ssh {
  $public = lookup('profile::ssh::public', {
    'default_value' => false,
    'value_type'    => Boolean, 
  })

  # If we consider the server to be publicly available, we limit the available
  # options for SSH a bit by only allowing 2fa-type of pubkeys.
  if($public) {
    $server_options = {
      'PubkeyAcceptedAlgorithms' => 'sk-ssh-ed25519@openssh.com',
    }

  # For the non-public servers we allow host-based auth for openstack/postgres
  # services.
  } else {
    $server_options = {
      'Match User postgres' => {
        'HostbasedAuthentication' => 'yes',
      },
      'Match User nova'     => {
        'HostbasedAuthentication' => 'yes',
      },
    }
  }

  if($::sl2 and $::sl2['server']['primary_interface']) {
    $listen = { 'ListenAddress' => [
      $::sl2['server']['primary_interface']['ipv4'],
      $::Sl2['server']['primary_interface']['ipv6'],
    ] - undef }

    if(length($listn['ListenAddress']) > 0) {
      $listen_real = $listen
    } else {
      $listen_real = {}
    }
  } else {
    $listen_real = {}
  }


  class {'::ssh':
    server_options => $server_options + $listen_real,
    client_options => {
      'Host *' => {
        'HostbasedAuthentication' => 'yes',
        'EnableSSHKeysign'        => 'yes',
        'HashKnownHosts'          => 'yes',
        'SendEnv'                 => 'LANG LC_*',
      },
    },
  }

  exec {'shosts.equiv':
    command => 'cat /etc/ssh/ssh_known_hosts | grep -v "^#" | \
                awk \'{print $1}\' | sed -e \'s/,/\n/g\' > \
                /etc/ssh/shosts.equiv',
    path    => '/bin:/usr/bin',
    unless  => '[ $(md5sum /etc/ssh/shosts.equiv | awk \'{print $1;}\') == \
                $(cat /etc/ssh/ssh_known_hosts | grep -v "^#" | awk \
                \'{print $1}\' | sed -e \'s/,/\n/g\' | md5sum | awk \
                \'{print $1}\') ];',
    require => Class['ssh::knownhosts'],
  }
}
