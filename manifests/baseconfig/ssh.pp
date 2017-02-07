# This class configures ssh and distributes ssh public keys.
class profile::baseconfig::ssh {
  # If the puppet-version is new enough to support ecda ssh-keys (which is
  # default in openssh these days), configure ssh. If puppet is too old; it
  # should be updated so that ssh gets configured... :)
  if ($::puppetversion > '3.5.0') {
    class {'::ssh':
      server_options => {
        'Match User nova' => {
          'HostbasedAuthentication' => 'yes',
        },
      },
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
      require => Class['ssh::knownhosts'],
    }
  }
}
